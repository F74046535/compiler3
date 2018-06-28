.class public main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 10
.limit locals 10
ldc	10.000000
istore	0
iload	0
ldc 10
isub
ifge Label_0
iload	0
ldc	1
iadd
istore	0
Label_0:
iload	0
ldc 10
isub
ifne Label_1
iload	0
ldc	1
isub
istore	0
Label_1:
iload	0
ldc 9
isub
ifne Label_2
ldc 20
istore	0
goto EXIT_0:
Label_2:
ldc 0
istore	0
EXIT_0:
return
.end method
