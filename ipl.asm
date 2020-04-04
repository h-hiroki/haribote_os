; hello-os
; TAB=4

    ORG     0x7c00          ; このプログラムが何処によみこまれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

    JMP     entry
    DB      0x90
    DB      "HELLOIPL"
    DW      512             ; 1セクタの大きさ                           (512にしなければならない)
    DB      1               ; クラスタの大きさ                          (1セクタにしなければならない)
    DW      1               ; FATがどこから始まるか                     (普通は1セクタ目からにする)
    DB      2               ; FATの個数                                 (2にしなければならない)
    DW      224             ; ルートディレクトリ領域の大きさ            (普通は224エントリにする)
    DW      2880            ; このドライブの大きさ                      (2880セクタにしなければならない)
    DB      0xf0            ; メディアタイプ                            (0xf0にしなければならない)
    DW      9               ; FAT領域の長さ                             (9セクタにしなければならない)
    DW      18              ; 1トラックにいくつのセクタがあるか         (18にしなければならない)
    DW      2               ; ヘッドの数                                (2にしなければならない)
    DD      0               ; パーティションを使っていないのでここは必ず0
    DD      2880            ; このドライブの大きさをもう一度書く
    DB      0, 0, 0x29      ; よくわからないけどこの値にしておくといいらしい
    DD      0xffffffff      ; たぶんボリュームシリアル番号
    DB      "HELLO-OS"      ; ディスクの名前                            (11Byte)
    DB      "FAT12"         ; フォーマットの名前                        (8Byte)
    RESB    18              ; とりあえず18バイト開けておく

; Program Main Body

entry:
    MOV     AX,0            ; レジスタ初期化
    MOV     SS,AX
    MOV     SP,0x7c00
    MOV     DS,AX
    ; MOV     ES,AX

    ; MOV     SI,msg

; Read disk

    MOV     AX,0x0820
    MOV     ES,AX
    MOV     CH,0            ; シリンダ0
    MOV     DH,0            ; ヘッド0
    MOV     CL,2            ; セクタ2

    MOV     SI,0            ; 失敗回数を数えるレジスタ
retry:
    MOV     AH,0x02         ; AH=0x02 : ディスク読み込み
    MOV     AL,1            ; 1セクタ
    MOV     BX,0
    MOV     DL,0x00         ; Aドライブ
    INT     0x13            ; ディスクBIOS呼び出し
    JNC     fin             ; エラーが置きなければfinへ
    ADD     SI,1            ; SIに1を足す
    CMP     SI,5            ; SIと5を比較
    JAE     error           ; SI >= 5 だったらerrorへ
    MOV     AH,0x00
    MOV     DL,0x00         ; Aドライブ
    INT     0x13            ; ドライブのリセット
    JMP     retry

fin:
    HLT                     ; 何かあるまでCPUを停止させる
    JMP     fin             ; 無限ループ

error:
    MOV     SI,msg

putloop:
    MOV     AL,[SI]
    ADD     SI,1            ; SIに1を足す
    CMP     AL,0
    JE      fin
    MOV     AH,0x0e         ; 一文字表示ファンクション
    MOV     BX,15           ; カラーコード
    INT     0x10            ; ビデオBIOS呼び出し
    JMP     putloop

msg:
    DB      0x0a, 0x0a      ; 改行を2つ
    DB      "hello, world"
    DB      0x0a            ; 改行
    DB      0

    ;RESB    0x7dfe-$        ; エラーになる。。。
    RESB	0x7dfe-0x7c00-($-$$)		; 0x7dfeまでを0x00で埋める命令
    DB      0x55, 0xaa


; 以下はブートセクタ以外の部分の記述

    DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB    4600
    DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB    1469432
