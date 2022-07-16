# ISUCON-scripts

ISUCONの汎用的なスクリプト集

問題発表後、サーバー側に git clone してスクリプトをシュッと使うイメージ。

利用規約に反していないか要確認。https://isucon.net/archives/56671734.html 読む限りは大丈夫そう？

# 汎用的な流れ

1. セットアップ
2. ベンチマーク
3. 改善ポイントを各自見つけて競技レポにコミット
4. ２と３を死ぬまで回す


## セットアップ　その１

0. （アプリケーションマニュアルの読み合わせ）
1. AMIからEC2インスタンスをつくる（複数台つくっておく）
2. SSH鍵をつくってメンバーに配る (SSH疎通確認)
3. `sudo -iu isucon`
4. **初期状態の全てのインスタンスのバックアップスナップショットをとっておく**

## セットアップ　その２

1. 競技コードのGitレポ化
  - Git init . して、 github.com/kenzan100 のプライベートレポにプッシュしておく
  - その後の変更は、そちらでPRを出す形
2. ISUCON-Script（このレポ）を、競技マシンにプッシュする
  - デプロイシェルなど、既に競技内容によらず定型化してあるものを、すぐに使う目的
3. 残りのセットアップは、ISUCON-Scriptで定型化できてあるはずなので、それを参照

### Symlinkでレポ外の設定ファイルを管理する

1. MySQLは、`ln`でハードリンクじゃないとNot foundって言われた。Apparmourのせい。
2. Nginxは、`ln -s`で大丈夫だった。

両方とも、実体ファイルをレポ内に動かしてから、シムリンクを貼る。

MySQL Apparmour
```
/etc/apparmor.d$ sudo vi usr.sbin.mysqld
```

```
# Allow config access for isucon
  /home/isucon/private_isu/** r,
```

```
systemctl restart apparmor
```


### 3. は まだできてないので、とりあえず洗い出し
- top
- https://github.com/raboof/nethogs 入れる
- ps -aux
- 構成把握図を、なんかざっとFigjamとかに書きそう

- ログファイルの、各構成要素のありか（なければ有効化）
- 同じく、各要素のconfのありか（書き換えられる場所の特定）
- アプケーションコードもざっと読む

- Alpのセットアップ（そのために、ログフォーマットを変更しておく）
- 


### デプロイ・ベンチ・集計を回すための準備

- マクロベンチ：Nginx access log | Alp
- マイクロ：Slow Query log | pt query log
- 監視：Netdata or Prometheus?


## Default editor to VIM

`sudo update-alternatives --set editor /usr/bin/vim.basic`

## Install Latest Docker

https://matsuand.github.io/docs.docker.jp.onthefly/engine/install/ubuntu/#installation-methods

## "Too many open files" でやれること

- `for pid in /proc/[0-9]*; do p=$(basename $pid); printf "%4d FDs for PID %6d; command=%s\n" $(ls $pid/fd | wc -l) $p "$(ps -p $p -o comm=)"; done | sort -n` で、何が fd とってるかみる
- それに対して、 systemctl edit <service-name> で、[Service] FileNOFILEを増やす
- Nginx の場合は、 `worker_rlimit_nofile` も増やす

## Alp

```
##
# Logging Settings
##

log_format ltsv "time:$time_local"
  "\thost:$remote_addr"
  "\tforwardedfor:$http_x_forwarded_for"
  "\treq:$request"
  "\tstatus:$status"
  "\tmethod:$request_method"
  "\turi:$request_uri"
  "\tsize:$body_bytes_sent"
  "\treferer:$http_referer"
  "\tua:$http_user_agent"
  "\treqtime:$request_time"
  "\tcache:$upstream_http_x_cache"
  "\truntime:$upstream_http_x_runtime"
  "\tapptime:$upstream_response_time"
  "\tvhost:$host";
access_log /home/isucon/nginx_access.log ltsv;
error_log /var/log/nginx/error.log;
```

## Redis

install and run under systemd
https://phoenixnap.com/kb/install-redis-on-ubuntu-20-04


## Port forwarding

https://github.com/isucon/isucon11-final/blob/main/docs/manual.md#%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E5%8B%95%E4%BD%9C%E7%A2%BA%E8%AA%8D

## Mysql in another machine

https://phoenixnap.com/kb/mysql-remote-connection
and bind address on mysqld.conf

## How to use limited ports to internal bigger ports (e.g. 80 -> 3306)

https://superuser.com/questions/661772/iptables-redirect-to-localhost#807612

## Datadog

- US1を使う。そうじゃないとDPMが使えない
- Datadog-agent自体はAutoInstallerでほぼ迷わずいける（終了前にUninstallを忘れないで
- DPMは、 https://docs.datadoghq.com/database_monitoring/setup_mysql/selfhosted/?tabs=mysql56 をやればいけた
- APMは、 dd trace on Sinatra で、ダッシュボードのIntegrationからいけた
- APMは、https://docs.datadoghq.com/tracing/trace_collection/dd_libraries/ruby/#mysql2 らへんでもっと色々リッチにできる
- APM - `c.profiling.enabled = true` もやりたかったが、まだ試してない (https://docs.datadoghq.com/tracing/profiler/enabling/ruby/?tabs=incode でいけるはず)

  
## Journal CTL
  
- `sudo journalctl -eu <service name>`
- `/etc/systemd/journal.conf` Storage=none to supress
