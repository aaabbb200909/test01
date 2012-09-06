
[イントロダクション]
tpupp.pl, tpupp.pyは、Puppetが使えない環境で、ファイルの同期状態を確認するための仕組みです。
実施することは以下となります。

--tpupp.py--
・Puppetサーバー上にあるファイルのcksumを取得し、httpで値を配布します。また、ファイル名指定でよばれた場合、該当のファイルをhttpで返します。


//
[tatsuya@scfc-virt2 tinypuppet]$ curl http://localhost/tpupp.py
4294967295 0 /tmp/bbb
1057305110 43 /tmp/bbb1
1884445191 43 /tmp/bbb2
2712396340 43 /tmp/bbb3
[tatsuya@scfc-virt2 tinypuppet]$ curl http://localhost/tpupp.py?filename=/tmp/bbb1
2012年  1月 15日 日曜日 19:49:44 JST
[tatsuya@scfc-virt2 tinypuppet]$ cat /var/tmp/tmp/bbb1 
2012年  1月 15日 日曜日 19:49:44 JST
[tatsuya@scfc-virt2 tinypuppet]$ 
//

-tpupp.pl-
※ tpupp.pyと連携して動作します。
まず、最初に、tpupp.pyから指定されたファイル全体のcksumを取得し、その値と該当サーバー上のファイルから生成したチェックサムを比較します。ここで、cksumが異なった場合には、tpupp.plはスクリプト内で指定された一時ディレクトリにtpupp.pyで配布されるファイル(レポジトリ側のファイル、と呼ぶ)を配置し、該当サーバーのファイルとのdiffを取得します。


///
[tatsuya@scfc-virt2 tinypuppet]$ ./tpupp.pl 
/tmp/bbb3 is different
1c1
< 2012年  1月 15日 日曜日 19:49:46 JST
---
> 2012年  1月 22日 日曜日 00:03:04 JST
[tatsuya@scfc-virt2 tinypuppet]$ 
///



[使用方法]
・ tpupp.py
Webサーバー上でPythonのCGIが実行できる任意の場所に配置します。通常はDocumentRootの直下(RHELでは/var/www/html/ ) に配置するのがよいと思います。

・ tpupp.pl
サーバー上で次の形式で実行します。
$ tpupp.pl
※ 正しく動作させるには、cksumを確認する対象のファイルへの読み取り権限と、一時ディレクトリへの書き込み権限が必要です。


[事前設定]
・tpupp.py
tpupp.py内では実際にcksumで管理するファイルを列記してあります。ファイルは複数指定できますが、指定したファイルの相対パスは、実際に配置されるパスと一致している必要があります。


・tpupp.pl
tpupp.plは3つの設定項目があります。
これらはファイルの配置時に、個別に設定する必要があります。
--
$server="localhost"; <==
実際にファイルが置かれているサーバー名
$pyfile="tpupp.py"; 
 <== 実際のCGIファイルの名称 (通常はtpupp.pyで固定)
$tmpdir="/tmp/tpupp";
 <==サーバー側の一時ファイルの置き場所
--


[制限事項]
 ・tpupp.pyは、PythonのCGIが動作するWebサーバーが無いと動作しません。また、Webサーバーにではcksumコマンドが使用できる必要があります。
  ※ tpupp.py側のファイルは配布先サーバーの元データとしたいため、tpupp.pyで配布するファイルは、Git等で管理を行うことを推奨します。
 ・tpupp.plが動作するには、いくつかの条件を満たす必要があります。
 1. diff, cksumコマンドが使用できる。
 2. HTTP::Liteのパッケージが使用できる。(インストールが不可能な場合、tpupp.plのあるディレクトリに、HTTP/Lite.pm の形でパッケージを配置することで、使用可能となります。)
 ・Puppetサーバー側に空のファイルを置いて同期しようとすると、上手く動作しません。

