unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Math, StdCtrls, Buttons, Registry, ComCtrls;

type
  TForm1 = class(TForm)
    PanelBas: TPanel;
    Shape: TShape;
    lTime: TStaticText;
    Timer: TTimer;
    TimerGagne: TTimer;
    btRandom: TSpeedButton;
    Bevel2: TBevel;
    OpenDialog: TOpenDialog;
    lNiveaux: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    UpDown: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure Clicks(Sender: TObject);
    procedure btRandomClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TimerGagneTimer(Sender: TObject);
    procedure MouseDowns(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseUps(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
  private
    { Declarations privees }
    procedure ModifPanel(const Col, Row: Integer; const SetOldSender: Boolean = False);
    procedure FreePanels;
    procedure AssigneCouleurs;
    function LoadLevel(const NumNiveau: Integer): Boolean;
  public
    { Declarations publiques }
  end;

var
  Form1: TForm1;
  TabColors: array[Boolean] of TColor;
  TabPanels: array of TPanel;
  NbPanels: Integer;
  GTC1: Cardinal;
  MaxVal: Integer = 3;
  Largeur: Integer = 65;
  NiveauEnCours: Integer = -1;
  ModeTriche: Boolean = False;
  OldSender: TComponent;
  slLgh: TStringList;
  NbNiveaux: Integer=0;
  LeNiveau: string='';

const
  FCaption = 'Lights - 1.4';  

implementation

{$R *.dfm}

Function ExtraitMot(Num : Integer; Ligne : String; Separator : String=':') : String;
Var
  PosSep,
  NBMots : Integer;
  MotLu, Lig  : String;
begin
  Result := '';
  If Ligne <> '' then
  begin
    NBMots := 0;
    Lig    := Ligne;
    If Lig[Length(Lig)] <> Separator then Lig := Lig + Separator;
    PosSep := Pos(Separator, Lig);
    While (PosSep > 0) and (Num <> NBMots) do
    begin
      MotLu := Copy(Lig, 1, PosSep-1);
      Lig   := Copy(Lig, PosSep+1, Length(Lig));
      Inc(NBMots);
      PosSep := Pos(Separator, Lig);
    end;
    Result := MotLu;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var N: Integer;
    i: Integer;
begin
  if Sender=Form1 then
  begin
    Randomize;
    slLgh:= TStringList.Create;
    if FileExists(ChangeFileExt(Application.ExeName,'.lgh')) then
      slLgh.LoadFromFile(ChangeFileExt(Application.ExeName,'.lgh'));
    slLgh.Insert(0, '4|65|0|New level 1|1100100000010011');
    NbNiveaux:= slLgh.Count;
    NiveauEnCours:= 1;
    lNiveaux.Caption:= IntToStr(NiveauEnCours)+'/'+IntToStr(NbNiveaux);
    UpDown.Max:= NbNiveaux;
    TabColors[False] := clLime;
    TabColors[True]  := clGreen;
  end;
  if (Sender=Form1) or (Sender=btRandom) then
  begin
    for i:= 1 to ParamCount do
    begin
      if Pos('/cases:', ParamStr(i))>0 then
      begin
        MaxVal:= StrToInt(ExtraitMot(2, ParamStr(i)))-1;
        if Maxval=0 then MaxVal:= 3;
        if MaxVal<2 then MaxVal:= 2;
        if MaxVal>9 then MaxVal:= 9;
      end;
      if Pos('/largeur:', ParamStr(i))>0 then
      begin
        Largeur:= StrToInt(ExtraitMot(2, ParamStr(i)));
        if Largeur=0 then Largeur:= 65;
        if Largeur<25 then Largeur:= 25;
        if Largeur>200 then Largeur:= 200;
      end;
      if not ModeTriche then
        ModeTriche:= Pos('cheat', ParamStr(i))>0;
    end;
    if ModeTriche then
      Caption:= FCaption + ' (Cheat actif)';
  end;
  ClientWidth:= (Largeur + 8) * (MaxVal+1) + 8;
  ClientHeight:= Width + PanelBas.Height;
  NbPanels:= Sqr(MaxVal+1);
  SetLength(TabPanels, NbPanels+1);
  for N:= 0 to NbPanels-1 do
  begin
    TabPanels[N]:= TPanel.Create(Self);
    TabPanels[N].Parent  := Form1;
    TabPanels[N].Width   := Largeur;
    TabPanels[N].Height  := Largeur;
    TabPanels[N].Tag     := ((N) mod (MaxVal+1)) + (10*((N) div (MaxVal+1)));
    TabPanels[N].Name    := 'PAN'+IntToStr(TabPanels[N].Tag div 10) + IntToStr(TabPanels[N].Tag mod 10);
    TabPanels[N].Caption := '';
    TabPanels[N].Hint    := '0';
    TabPanels[N].Top     := 8 + (Largeur+8) * (N div (MaxVal+1));
    TabPanels[N].Left    := 8 + (Largeur+8) * (N mod (MaxVal+1));
    TabPanels[N].Color   := clGreen;
    TabPanels[N].Cursor  := crHandPoint;
    TabPanels[N].BevelWidth:= 2;
    TabPanels[N].Font.Size := 10;
    TabPanels[N].Font.Color:= clRed;
    TabPanels[N].Font.Name := 'Trebuchet MS';
    TabPanels[N].OnClick   := Clicks;
    TabPanels[N].OnMouseDown := MouseDowns;
    TabPanels[N].OnMouseUp   := MouseUps;
  end;
  GTC1:= 0;
  if Sender=Form1 then
    LoadLevel(1);
end;

procedure Gagne;
begin
  GTC1:= 0;
  Form1.Timer.Enabled:= False;
  Form1.TimerGagne.Enabled:= True;
end;

function VerifWin: Boolean;
var i, X: integer;
begin
  X:= 0;
  for i:= 0 to NbPanels-1 do
    Inc(X, StrToInt(TabPanels[i].Hint));
  Result:= ((X=0) and (Form1.Shape.Brush.Color=clGreen)) or ((X=NbPanels) and (Form1.Shape.Brush.Color=clLime));
end;

procedure TForm1.ModifPanel(const Col, Row: Integer; const SetOldSender: Boolean = False);
var Compo: TComponent;
begin
  if Assigned(OldSender) and SetOldSender then
    TPanel(OldSender).Caption:= '';
  Compo:= FindComponent('PAN'+IntToSTr(Col)+IntToStr(Row));
  if SetOldSender then
    OldSender:= Compo;
  if Assigned(Compo) then
  begin
    TPanel(Compo).Color:= TabColors[TPanel(Compo).Color=TabColors[False]];
    if TPanel(Compo).Hint='0' then
         TPanel(Compo).Hint:='1'
    else TPanel(Compo).Hint:='0';
  end;
end;

procedure TForm1.Clicks(Sender: TObject);
var col, row: integer;
begin
  if TimerGagne.Enabled then
    Exit;
  col := TPanel(sender).Tag div 10;
  row := TPanel(sender).Tag mod 10;
  ModifPanel(col, row, True);
  TPanel(Sender).Caption:= '.';
  ModifPanel(col-1, row);
  ModifPanel(col, row-1);
  ModifPanel(col+1, row);
  ModifPanel(col, row+1);
  if VerifWin then
    Gagne;
  if GTC1=0 then
    GTC1:= GetTickCount;
  Timer.Enabled:= True;
end;

procedure TForm1.btRandomClick(Sender: TObject);
var tag, i: Integer;
    Compo: TComponent;
begin
  if Sender<>nil then
  begin
    FreePanels;
    FormCreate(btRandom);
  end;
  for i:= 0 to NbPanels-1 do
  begin
    if Sender<>nil then
    begin
      lNiveaux.Caption:= 'Aleatoire';
      UpDown.Position:= 1;
      Caption:= FCaption;
    end;
    tag:= ((i) mod (MaxVal+1)) + (10*((i) div (MaxVal+1)));
    Compo:= FindComponent('PAN'+IntToStr(Tag div 10) + IntToStr(Tag mod 10));
    if Assigned(Compo) then
    begin
      TPanel(Compo).Caption:= '';
      if Odd(Random(2)) then
      begin
        TPanel(Compo).Color:= TabColors[TPanel(Compo).Color=TabColors[False]];
        if Sender=nil then
          if not ModeTriche then
               TPanel(Compo).Caption:= 'GAGNE'
          else TPanel(Compo).Caption:= 'TRICHEUR';
        if TPanel(Compo).Hint='0' then
             TPanel(Compo).Hint:='1'
        else TPanel(Compo).Hint:='0';
      end
      else
      if Sender=nil then
        if not ModeTriche then
             TPanel(Compo).Caption:= 'WINNNER'
        else TPanel(Compo).Caption:= 'CHEATER';
      Shape.Brush.Color:= TPanel(Compo).Color;
    end;
  end;
  if Sender<>nil then
  begin
    GTC1:=0;
    lTime.Caption:= '0 sec.';
    TimerGagne.Enabled:= False;
    Shape.Visible:= True;
  end;
  if VerifWin then
    Gagne;
  Timer.Enabled:= False;
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
  lTime.Caption:= IntToStr((GetTickCount - GTC1) div 1000)+' sec.';
end;

procedure TForm1.TimerGagneTimer(Sender: TObject);
begin
  btRandomClick(nil);
end;

procedure TForm1.MouseDowns(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var col, row: integer;
begin
  if (Button = mbLeft) and (ssLeft in Shift) then
  begin
    TPanel(Sender).BevelInner:= bvLowered;
    TPanel(Sender).BevelOuter:= bvNone;
  end;
  if TimerGagne.Enabled or not ModeTriche then
    Exit;
  if Button = mbMiddle then
  begin
    if GTC1=0 then
      GTC1:= GetTickCount;
    Timer.Enabled:= True;
    col := TPanel(sender).Tag div 10;
    row := TPanel(sender).Tag mod 10;
    ModifPanel(col, row);
    if VerifWin then
      Gagne;
  end;
end;

procedure TForm1.MouseUps(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  TPanel(Sender).BevelInner:= bvNone;
  TPanel(Sender).BevelOuter:= bvRaised;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreePanels;
  FreeAndNil(slLgh);
end;

procedure TForm1.AssigneCouleurs;
var x, y, Lettre: Integer;
    Compo: TComponent;
begin
  Lettre:= 1;
  for y:=0 to MaxVal do
    for x:= 0 to MaxVal do
    begin
      Compo:= FindComponent('PAN'+IntToStr(y) + IntToStr(x));
      if Assigned(Compo) then
      begin
        TPanel(Compo).Color:= TabColors[LeNiveau[Lettre]='0'];
        TPanel(Compo).Hint:= LeNiveau[Lettre];
        TPanel(Compo).Caption:= '';
      end;
      Inc(Lettre);
    end;
end;

function TForm1.LoadLevel(const NumNiveau: Integer): Boolean;
var Niveau, Titre: string;
begin
  Result:= True;
  FreePanels;
  Niveau:= slLgh[NumNiveau-1];
  MaxVal:=  StrToInt(ExtraitMot(1, Niveau, '|'))-1;
  if MaxVal=0 then MaxVal:= 3;
  if MaxVal<2 then MaxVal:= 2;
  if MaxVal>9 then MaxVal:= 9;
  Largeur:= StrToInt(ExtraitMot(2, Niveau, '|'));
  if Largeur=0 then Largeur:= 65;
  if Largeur<25 then Largeur:= 25;
  if Largeur>200 then Largeur:= 200;
  Shape.Brush.Color:= TabColors[not (ExtraitMot(3, Niveau, '|')='1')];
  Titre:= ExtraitMot(4, Niveau, '|');
  Niveau:= ExtraitMot(5, Niveau, '|');
  Caption:= FCaption + ' - ' + Titre;
  NbPanels:= Sqr(MaxVal+1);
  FormCreate(nil);
  LeNiveau:= Niveau;
  Niveau:= StringReplace(Niveau,'1','',[rfReplaceAll]);
  Niveau:= StringReplace(Niveau,'0','',[rfReplaceAll]);
  if (Length(LeNiveau)<>NbPanels) or (Length(Niveau)<>0) then // 102
  begin
    MessageDlg('Fichier non valide. Code Erreur 102', mtError, [mbAbort], 0);
    Result:= False;
  end;
  if Result then
  begin
    AssigneCouleurs;
    GTC1:=0;
    lTime.Caption:= '0 sec.';
    TimerGagne.Enabled:= False;
    Shape.Visible:= True;
    Timer.Enabled:= False;
    lNiveaux.Caption:= IntToStr(NiveauEnCours)+'/'+IntToStr(NbNiveaux);
  end;
end;

procedure TForm1.FreePanels;
var i: Integer;
begin
  for i:=0 to NbPanels-1 do
    TabPanels[i].Free;
  SetLength(TabPanels, 0);
  OldSender:= nil;
end;

procedure TForm1.UpDownClick(Sender: TObject; Button: TUDBtnType);
begin
  NiveauEnCours:= UpDown.Position;
  LoadLevel(NiveauEnCours);
end;

end.