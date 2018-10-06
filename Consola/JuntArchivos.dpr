program JuntArchivos;

uses  Funciones in 'Funciones.pas';
{$APPTYPE CONSOLE} {$H+}  {$R *.RES}
function inttostr(i: integer): string;
begin
  str(i, Result);
end;

procedure logotipo;
 begin
 writeln('************************************************************');
 writeln('*          ©©     ©©©   ©     ©   ©©©                      *');
 writeln('*         ©  ©    ©  ©  ©     ©  ©                         *');
 writeln('*        ©    ©   ©  ©   ©   ©   ©       ©©    ©©  ©       *');
 writeln('*        ©©©©©©   ©©     ©   ©    ©©©   ©  ©  ©    ©©      *');
 writeln('*       ©      ©  © ©     © ©        ©  ©  ©  ©©   ©       *');
 writeln('*       ©      ©  ©  ©     ©     ©©©©    ©©   ©    ©       *');
 writeln('*                                                          *');
 writeln('*            JuntArchivos de CortArchivos 2.0              *');
 writeln('************************************************************');
 Writeln('arvsoft@teleline.es  - http://www.terra.es/personal2/arvsoft');
 writeln('************************************************************');
end;

function StrRScan(Str: PChar; Chr: Char): PChar; assembler;
asm
        PUSH    EDI
        MOV     EDI,Str
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        STD
        DEC     EDI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     EAX,0
        JNE     @@1
        MOV     EAX,EDI
        INC     EAX
@@1:    CLD
        POP     EDI
end;

function NameExt(FileName: PChar): PChar;

 var
  P: PChar;
begin
  P := StrRScan(FileName, '\')+1;
  if P = nil then
  begin
    P := StrRScan(FileName, ':')+1;
    if P = nil then P := FileName;
  end;
  NameExt := P;
end;

function Getpath(filename, name: string): string;
var
  s: string;
  l: integer;
begin
 l:= length(filename)- length(name);
 s:= copy ( filename,1, l);
 Getpath:=s;
end;


var
 f, fexe: file;
 NumRead, NumWritten, size: integer;
 Buf: array[1..2048] of Char;
 bufHeader: string[7];
 bufInteger, count: integer;
 bufExt: string[4];
 FileName, FilePath, Name, Path, NamenoExt: ansistring;
begin //Begin Programa
  logotipo;
  FileName:= ParamStr(0);
  Name:= NameExt (pchar(filename));
  FilePath:= Getpath(filename, name);
  NamenoExt:= copy (name, 1, length(name)-8);
  if namenoExt='JuntArch' then exit;
  AssignFile(f, filepath + namenoext + '.fin');
  Reset(F, 1);
  if ioresult<>0 then
  begin
    writeln;
    writeln('ERROR no se encuentra ' + Namenoext +'.fin' );
    writeln('Pulse ENTER para Salir');
    readln;
    exit;
  end ;
  size:= filesize(f);
  BlockRead(f, bufHeader, SizeOf(bufHeader), NumRead);
  if bufheader<>'cortarc' then
  begin
    writeln('!!!ERROR!!!: el fichero ' + name +
             '.fin no ha sido cortado con CortArchivos' );
    writeln('Pulse ENTER para Salir');
    readln;
    exit;
  end ;
  BlockRead(f, bufInteger, SizeOf(bufInteger), NumRead);
  writeln;
  write ('Numero de archivos para unir: ');
  writeln(bufInteger);
  BlockRead(f, bufExt, SizeOf(bufExt), NumRead);
  write ('Nombre de archivo original: ');
  writeln(NamenoExt + bufExt);
  CloseFile(f);
  writeln('Pulse ENTER para continuar');
  readln;
  //*********

AssignFile(fexe, filepath + NamenoExt + bufExt);
Rewrite(fexe, 1);
Writeln('Procesando...');
For count:= 1 to bufinteger-1 do
begin
  AssignFile(f, filepath + namenoExt + '.' + inttostr(count));
  Reset (f,1);
  if ioresult<>0 then
  begin
    writeln;
    writeln('!!!ERROR!!!: no se encuentra ' + Namenoext + '.' + inttostr(count));
    writeln('Pulse ENTER para Salir');
    readln;
    exit;
  end ;
  repeat
    BlockRead(f, Buf, SizeOf(Buf), NumRead);
    BlockWrite(fexe, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  CloseFile(f);
  Writeln(namenoExt + '.' + inttostr(count));
end; //end for
//*******************fin*******************
AssignFile(f, filepath + namenoExt + '.fin');
Reset(F, 1);
seek(F, 17); //avanza hasta los datos
  repeat
    BlockRead(f, Buf, SizeOf(Buf), NumRead);
    BlockWrite(fexe, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  CloseFile(f);
  Writeln(NamenoExt + '.fin');
  closefile(fexe);
//Para terminar
Write('Se han unido los archivos y se ha creado: ');
Writeln(NamenoExt + bufExt);
writeln('Pulse Enter para Salir');
readln

end. //Se acabo



