unit UFrmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, FileCtrl;

type
  TFrmMain = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    TxtArchivo: TEdit;
    CmdBuscar: TBitBtn;
    GBtamano: TGroupBox;
    LblBytes: TLabel;
    LblKb: TLabel;
    LblMb: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    TxtTamanoTrozo: TEdit;
    CmdCortar: TBitBtn;
    BitBtn2: TBitBtn;
    CHkFitinDisk: TCheckBox;
    TxtnumTrozos: TEdit;
    TxtBytes1: TEdit;
    TxtBytes2: TEdit;
    OpenDlg: TOpenDialog;
    Label11: TLabel;
    TxtInitialDir: TEdit;
    Label12: TLabel;
    TxtMaxtrozos: TEdit;
    UpDown: TUpDown;
    Label13: TLabel;
    TxtMintrozo: TEdit;
    ChkSendTo: TCheckBox;
    ChkShellLink: TCheckBox;
    Panel: TPanel;
    Image1: TImage;
    REStatus: TRichEdit;
    ChkPrograms: TCheckBox;
    Panel1: TPanel;
    Label15: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    ChkUnir: TCheckBox;
    GroupBox1: TGroupBox;
    RadioB1: TRadioButton;
    RadioB2: TRadioButton;
    TxtSave: TEdit;
    CmdInitialDir: TButton;
    CmdSave: TButton;
    procedure CHkFitinDiskClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Activar (valor: Boolean);
    procedure CmdBuscarClick(Sender: TObject);
    procedure CmdCortarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TxtTamanoTrozoKeyPress(Sender: TObject; var Key: Char);
    procedure TxtTamanoTrozoChange(Sender: TObject);
    procedure EscribeBat (cadena: string);
    procedure ChkShellLinkClick(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure TxtMaxtrozosChange(Sender: TObject);
    procedure TxtMintrozoKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Label17Click(Sender: TObject);
    procedure Label14Click(Sender: TObject);
    procedure RadioB1Click(Sender: TObject);
    procedure CmdInitialDirClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private

  public
    procedure DropFiles (var Msg: TWmDropFiles); message wm_DropFiles;
    function ShellBrowse(sender: TObject): string;
  end;

var
  FrmMain: TFrmMain;
  iFileSize: cardinal;
  PathName, Path, NameExt, NameNoExt, Ext: Ansistring;
  bChangeReg: boolean;
implementation

{$R *.DFM}
uses shellapi,ComObj, ActiveX, ShlObj, Registry;

procedure TFrmMain.CHkFitinDiskClick(Sender: TObject);
begin
if ChkFitindisk.Checked then
  begin
    TxtTamanotrozo.Text := '1450000';
    TxtTamanotrozo.Enabled := false;
  end
  else TxtTamanotrozo.Enabled := true
end;

procedure TFrmMain.BitBtn2Click(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.Activar (valor: Boolean);
begin
  TxtTamanotrozo.enabled := valor;
  Chkunir.enabled := valor;
  ChkFitinDisk.enabled := valor;
  label5.enabled := valor;
  label6.enabled := valor;
  label7.enabled := valor;
  label8.enabled := valor;
  label9.enabled := valor;
  label10.enabled := valor;
  CmdCortar.enabled := valor
end;

procedure TFrmMain.CmdBuscarClick(Sender: TObject);

var
  F : file of byte;
  strformat : string;
  floatdummy: double;
  position : integer;
begin
if (Sender is TBitBtn) then
begin
  OpenDlg.InitialDir := TxtInitialDir.text;
  if(OpenDlg.execute) then TxtArchivo.Text := OpenDlg.Filename
  else exit;
end;
    PathName:= txtArchivo.text;
    Path:=ExtractFilePath (Pathname);
    Ext := ExtractFileExt (Pathname);
    NameExt:= ExtractFilename( Pathname);
    if Ext <>'' then
    begin
      position:= pos (Ext, NameExt);
      NamenoExt:= Copy (NameExt,1,position-1);
    end
    else
    NamenoExt := NameExt;
    AssignFile(F, txtarchivo.text);
    filemode:=0; //solo para ver el tama�o
    {$I-}
    Reset(F);
    {$I+}
    if IOResult <> 0 then
    begin
      MessageDlg('Error de acceso al archivo', mtWarning, [mbOk], 0);
      exit;
    end;
    floatdummy:= Filesize(F);
    iFileSize:= Trunc(floatdummy);
    Closefile (f);
    strformat:='%.0n';
    lblbytes.caption:= Format(strformat, [floatdummy]);
    strformat:='%.2n';
    floatdummy := floatdummy /1024;
    lblKb.caption:= Format(strformat, [floatdummy]);
    Floatdummy:= floatdummy/1024;
    lblMb.caption:= Format(strformat, [floatdummy]);
    Activar (true);
    TxtTamanotrozo.text:='';
    TxtBytes1.text:='';
    TxtBytes2.text:= '';
    TxtNumtrozos.text:= '';
end;

procedure TFrmMain.CmdCortarClick(Sender: TObject);
Const
  comilla ='"';
var
  FinalSize, FinalSize2, numtrozos: cardinal;
  f : integer;
  StreamOrig, StreamCopia : TFileStream;
  S, sbat, fromfile, tofile: ansistring;
  cExt: string[4];
  cHeader: string[7];
  pfromFile, pTofile: pchar;
begin
  if txttamanotrozo.text ='' then
  begin
    beep;
    ShowMessage('Pon el tama�o de los trozos');
    exit;
  end;
  if strtoint(txttamanotrozo.text)< Strtoint (TxtMinTrozo.text) then
  begin
    beep;
    ShowMessage('Los trozos no pueden ser menores de '
                 + TxtMinTrozo.text + ' bytes');
    exit;
  end;
  Finalsize := strtoint (txtTamanotrozo.text);
  if FinalSize >= iFilesize then
  begin
    beep;
    ShowMessage ('Los trozos son mayores o igual que el tama�o original');
    exit;
  end;
  numtrozos := iFilesize div Finalsize; //n de trozos(el ultimo quizas no lleno
  if iFilesize mod FinalSize <> 0 then inc(numtrozos);
  if numtrozos > Strtoint(TxtMaxTrozos.text) then
  begin
    beep;
    ShowMessage ('No se pueden hacer mas de ' + txtMaxtrozos.text + ' trozos');
    exit;
  end;
  Finalsize2 := iFilesize - (FinalSize* (numtrozos -1));
  CMdCortar.enabled := false; //Evitar doble click
  CmdBuscar.enabled:=false; //id
  Restatus.clear;
  sbat:= '';
  //Empezar a cortar
  StreamOrig := TFileStream.create (PathName, fmOpenRead);
  if radioB2.checked then
  begin
    if DirectoryExists(txtsave.text+ '\')=false then
      if MessageDlg ('No existe la carpeta de destino:'+ #13 + txtsave.text +
                 #13 +'�Desea Crearla o Cancelar?',
                 mtWarning, [mbYes, mbCancel], 0) = mrYes then
      begin
        mkdir (txtsave.text);
        path:= txtsave.text +'\';
      end
      else
      begin
        StreamOrig.free;
        CmdBuscar.enabled:=true;
        Activar (false);
        exit;
      end;
    path:= txtsave.text +'\';
  end;
  S:= 'Creando Archivos Cortados:';
  ReStatus.SelAttributes.color:= clred;
  REStatus.Lines.add (s);
  REstatus.Refresh ;
  For f := 1 to numtrozos do
    begin
      if f< numtrozos then
        begin
          try
            StreamCopia:= TFileStream.create  //PATH OPCIONAL
            ((Path + NameNoExt + '.' + inttostr(f)), fmOpenWrite or fmCreate);
            streamCopia.CopyFrom (StreamOrig, Finalsize);
            sbat:= sbat + comilla + NameNoExt+ '.'
                   + inttostr(f) + comilla + ' + ';
            S:= NameNoExt + '.'  + (inttostr(f)) ;
          finally
            StreamCopia.Free;
          end;
        end  //end if
      else
        begin   //Ultimo trozo
          try
            StreamCopia:= TFileStream.create
            ((Path + NameNoExt + '.fin'), fmOpenWrite or fmCreate);
      if chkUnir.checked then
      begin
      FillChar(cHeader, SizeOf(cHeader), 0);
      cHeader:= 'cortarc';
      Streamcopia.WriteBuffer (cHeader, sizeof(cheader));
      Streamcopia.WriteBuffer (integer(numtrozos), sizeof(integer));
      FillChar(cExt, SizeOf(cExt), 0);
      cExt:= Ext;
      Streamcopia.WriteBuffer (cExt, sizeof(cExt));
      end;
            streamCopia.CopyFrom (StreamOrig, Finalsize2);
            sbat:= sbat + comilla + NameNoExt+ '.fin' + comilla ;
            S:= NameNoExt + '.fin';
          finally
            StreamCopia.Free;
          end;
      end; //end else
        ReStatus.SelAttributes.color:= clNavy;
        REStatus.Lines.add (s);
        ReStatus.Refresh ;
    end; //end for }
  StreamOrig.free;
  S:= 'Creando Archivo para Uni�n:';
  ReStatus.SelAttributes.color:= clRed;
  REStatus.Lines.add (s);
  if not(chkUnir.checked) then
  begin
    EscribeBat (sbat);
    S:= NameNoExt +'UNIR' +  '.BAT';
  end
  else
  begin
  S:= NamenoExt +'UNIR.exe';
  //copiar juntarchivos y renombrarlo
  fromFile:= extractfilepath(paramstr(0));
  fromFile:= fromfile + 'JuntArchivos.exe';
  pfromfile:= pchar(fromfile);
  Tofile:= path + NamenoExt + 'UNIR.exe'; // PATH OPCIONAL
  pToFile:= pchar(ToFile);
  copyfile (pfromfile, ptofile, false );
  end;
  ReStatus.SelAttributes.color:= clNavy;
  REStatus.Lines.add (s);
  S:= 'FIN del Proceso.';
  ReStatus.SelAttributes.color:= clBlack ;
  REStatus.Lines.add (s);
  CmdBuscar.enabled:=true; //Restablecer
  Activar (false);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  Reg : TRegIniFile;
  spath: ansistring;
begin
if paramcount=1 then
begin
  TxtArchivo.text := ParamStr(1);
  FrmMain.CmdBuscarClick(self);
end;
  DragAcceptFiles (Handle, true);
  //Registro
  Reg := TRegIniFile.Create('\software\ARVSOFT\CortArchivos');
  ChkShellLink.Checked:= Reg.ReadBool('2.0', 'IconDesktop', false);
  ChkSendto.Checked := Reg.ReadBool('2.0', 'ContextMenu', false );
  Chkprograms.Checked := Reg.ReadBool('2.0', 'StartMenu', false );
  RadioB1.Checked := Reg.ReadBool('2.0', 'SameDir', true );
  RadioB2.Checked := Reg.ReadBool('2.0', 'OtherDir', false );
  spath:=Extractfilepath(paramstr(0));
  spath:= spath + 'Mis Archivos Cortados';
  TxtSave.Text:= Reg.ReadString('2.0', 'SaveDir',spath);  //Mis archivos...
  TxtInitialDir.Text:= Reg.ReadString('2.0', 'InitialDir','C:\');
  UpDown.Position := Reg.ReadInteger('2.0', 'Max', 50);
  Txtmintrozo.text := inttoStr(Reg.ReadInteger('2.0', 'Min', 16384));
  Reg.Free;
  bChangeReg:= false;
end;

procedure TFrmMain.TxtTamanoTrozoKeyPress(Sender: TObject; var Key: Char);
var
  tecla: Char;
  stamano:string;
begin
  tecla := key;
if (tecla in ['0'..'9']) or (tecla = #8) then
  begin
    if tecla <> #8 then
    begin
        stamano:= TxtTamanoTrozo.text;
        stamano:= stamano + tecla;
        if (strtoint(stamano))> iFileSize then
        begin
          Key:=#0;
          beep;
        end;
    end;
  end
else
  begin
    beep;
    key:=#0;
  end;
end;

procedure TFrmMain.TxtTamanoTrozoChange(Sender: TObject);
var
cTrozo: cardinal;
cNumtrozos: cardinal;
begin
  if length(TxtTamanoTrozo.text)= 0 then
  begin
    TxtBytes1.text:='';
    TxtBytes2.text:= '';
    TxtNumtrozos.text:= '';
    exit;
  end;
  cTrozo:= strtoint(TxttamanoTrozo.Text) ;
  if ctrozo>0 then
  begin
    TxtnumTrozos.Text := inttostr(iFileSize div cTrozo);
    TxtBytes1.text:= TxtTamanoTrozo.text;
    cNumtrozos :=strtoint(TxtnumTrozos.text);
    TxtBytes2.text:= inttostr(iFilesize- (ctrozo* cNumtrozos))
  end;
end;

procedure TFrmMain.EscribeBat (cadena: string);
var
  FileBat : TextFile;
  batName: string;
begin
  BatName := Path +  NameNoExt + '.bat';
  AssignFile (Filebat, batName);
  Rewrite (FileBat);
  writeln(Filebat, 'echo off');
  writeln (Filebat, 'echo CortArchivos 2.0');
  writeln(Filebat, 'echo Pegando archivos');
  writeln (Filebat, 'echo.');
  writeln(Filebat, 'echo Leyendo Archivos');
  writeln (filebat, 'copy /b ' + cadena + ' ' + '"' + NameExt + '"');
  writeln (Filebat, 'echo.');
  writeln (Filebat, 'echo SE HA PEGADO ' + nameExt);
  writeln (Filebat, 'PAUSE');
  CloseFile (FileBat);
end;

procedure TFrmMain.DropFiles(var Msg: TWmDropFiles);
//La Biblia de Delphi 5(Marco Cant�)
var
  nFiles: Integer;
  Filename: Ansistring;
begin
  // get the number of dropped files
  nFiles := DragQueryFile (Msg.Drop, $FFFFFFFF, nil, 0);
  if nFiles>1 then
    begin
      DragFinish (Msg.Drop);
      beep;
      setforegroundWindow (Application.Handle );
      ShowMessage('S�lo se puede arrastrar un archivo');
      exit;
    end;
  // for the file
  try
      // allocate memory
      SetLength (Filename, 80);  //�porque 80?
      // read the file name
      DragQueryFile (Msg.Drop, 0, (Pchar(Filename)), 80);
      // normalize file
      Filename := PChar (Filename);
      if ExtractFileExt (filename)= '' then
      begin
        DragFinish (Msg.Drop);
        beep;
        setforegroundWindow (Application.Handle );
        ShowMessage('No se pueden arrastrar archivos sin extension o carpetas');
        exit;
      end
      else
      begin
      TxtArchivo.text := Filename;
      FrmMain.CmdBuscarClick(self);
      end
  finally
    DragFinish (Msg.Drop);
  end;
end;

procedure TFrmMain.ChkShellLinkClick(Sender: TObject);
//La Biblia de Delphi 5(Marco Cant�)
var
  AnObj: IUnknown;
  ShLink: IShellLink;
  PFile: IPersistFile;
  FileName: ansistring;
  WFileName: WideString;
  Reg: TRegIniFile;
  sStringReg: string;
begin
  // access to the two interfaces of the object
  AnObj := CreateComObject (CLSID_ShellLink);
  ShLink := AnObj as IShellLink;
  PFile := AnObj as IPersistFile;
  // get the name of the application file
  FileName := ParamStr (0);
  // set the link properties
  ShLink.SetPath (PChar (FileName));
  ShLink.SetWorkingDirectory (PChar (
  ExtractFilePath (FileName)));
  if (Sender as Tcheckbox).name ='ChkShellLink' then
  begin
    sStringReg:= 'Software\MicroSoft\Windows\CurrentVersion\Explorer' ;
    Reg := TRegIniFile.Create (sstringReg);
    WFileName := Reg.ReadString ('Shell Folders', 'Desktop', '') +
      '\' + 'CortArchivos 2.0' + '.lnk';
    Reg.free;
    if ChkShellLink.Checked  then  PFile.Save (PWChar (WFileName), False)
     else deletefile (wfilename);
  end;
  if (Sender as Tcheckbox).name ='ChkPrograms' then
  begin
    sStringReg:= 'Software\MicroSoft\Windows\CurrentVersion\Explorer' ;
    Reg := TRegIniFile.Create (sstringReg);
    WFileName := Reg.ReadString ('Shell Folders', 'programs', '') +
      '\' + 'CortArchivos 2.0' + '.lnk';
    Reg.free;
    if Chkprograms.Checked  then  PFile.Save (PWChar (WFileName), False)
     else deletefile (wfilename);
  end;
  if (Sender as Tcheckbox).name ='ChkSendTo' then
  begin
    sStringReg:= 'Software\MicroSoft\Windows\CurrentVersion\Explorer' ;
    Reg := TRegIniFile.Create (sstringReg);
    WFileName := Reg.ReadString ('Shell Folders', 'Sendto', '') +
      '\' + 'CortArchivos 2.0' + '.lnk';
    Reg.free;
    if ChkSendTo.Checked  then  PFile.Save (PWChar (WFileName), False)
     else deletefile (wfilename);
  end;
bChangeReg:= true;
end;

function TFrmMain.ShellBrowse (Sender: Tobject): string ;
Var   //Programaci�n en Delphi4 (Francisco Chartre)
   Inf: TBrowseInfo;
   Identificador: PItemIDList;
   Gestor: IMalloc;
   Carpeta: Array[0..MAX_PATH] Of Char;
begin
     With Inf Do
      Begin // Inicializamos la estructura
           hwndOwner := Handle;
           pidlRoot := Nil;
           pszDisplayName := Carpeta;
           lpszTitle := 'Seleccione una carpeta';
           ulFlags :=BIF_RETURNONLYFSDIRS; // ***Sin archivos***
           lpfn := Nil;
      End;
          // Abrir el cuadro de di�logo para seleccionar una carpeta
     Identificador := SHBrowseForFolder(Inf);
       // Si no se ha pulsado el bot�n Cancelar
     If Identificador <> Nil Then
      Begin // Obtenemos el camino
           SHGetPathFromIDList(Identificador, Carpeta);
             // Liberamos el identificador
           SHGetMalloc(Gestor);
           Gestor.Free(Identificador);
             // y mostramos la carpeta elegida
           Result:= string(Carpeta);
      End
      else Result:='';
end;

procedure TFrmMain.PageControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
var
  Reg: TRegIniFile;
begin
If (bChangeReg) and (PageControl1.ActivePage = Tabsheet2) then
begin
  Reg := TRegIniFile.Create('\software\ARVSOFT\CortArchivos');
  Reg.WriteBool('2.0', 'IconDesktop', ChkShellLink.Checked);
  Reg.WriteBool('2.0', 'ContextMenu', ChkSendto.Checked);
  Reg.WriteBool('2.0', 'StartMenu', Chkprograms.Checked);
  Reg.WriteBool('2.0', 'SameDir', RadioB1.Checked);
  Reg.WriteBool('2.0', 'OtherDir', RadioB2.Checked);
  Reg.WriteString('2.0', 'InitialDir', TxtInitialDir.Text);
  Reg.WriteString('2.0', 'SaveDir', TxtSave.Text);
  Reg.WriteInteger('2.0', 'Max', UpDown.position);
  Reg.WriteInteger('2.0', 'Min', strtoint(Txtmintrozo.text));
  Reg.Free;
end;
bChangeReg:= false;
end;

procedure TFrmMain.TxtMaxtrozosChange(Sender: TObject);
begin
bChangeReg:= true;
end;

procedure TFrmMain.TxtMintrozoKeyPress(Sender: TObject; var Key: Char);
var
 tecla: Char;
begin
  tecla :=key ;
if not (tecla in ['0'..'9']) and (tecla <> #8)  then
  begin
  Key:=#0;
  beep;
  end;
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  bdummy: boolean;
begin
  bdummy:= true;
  CanClose:=False;
  If (bChangeReg) and (PageControl1.ActivePage = Tabsheet2) then
  if MessageDlg ('�Quiere guardar las opciones?',
                 mtWarning, [mbYes, mbNo], 0) = mrYes then
  FrmMain.PageControl1Changing(self, bdummy);
  CanClose:= true;
end;

procedure TFrmMain.Label17Click(Sender: TObject);
var
  dir :ansistring ;
  pdir: pchar;
begin
  dir:= 'mailto:' + Label17.Caption + '?Subject=CortArchivos2.0';
  pdir:= Pchar(dir);
  ShellExecute(GetDesktopWindow(),nil, pdir ,nil,
               nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.Label14Click(Sender: TObject);
var
  dir :ansistring ;
  pdir: pchar;
begin
  dir:=  Label14.Caption ;
  pdir:= Pchar(dir);
  ShellExecute(GetDesktopWindow(),nil, pdir ,nil,
               nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.RadioB1Click(Sender: TObject);
begin
  TxtSave.Enabled := Not Radiob1.checked;
  CMdSave.Enabled := Not Radiob1.checked;
end;

procedure TFrmMain.CmdInitialDirClick(Sender: TObject);
var dummy: string;
begin
  dummy:= shellbrowse(self );
  if dummy<>'' then TxtInitialDir.text:= dummy;
  BChangeReg:= True;
end;

procedure TFrmMain.Button1Click(Sender: TObject);
var dummy: string;
begin
  dummy:= shellbrowse(self);
  if dummy<>'' then Txtsave.text:= dummy;
  BChangeReg:= True;
end;

end. //Se acab�
