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
