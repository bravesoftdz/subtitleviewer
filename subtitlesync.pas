unit subtitlesync;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, ExtCtrls,subtitle,LCLType;

type

  { TForm2 }

  TForm2 = class(TForm)
   Button1: TButton;
   Button2: TButton;
   CheckBox1: TCheckBox;
   usedatapoints: TCheckBox;
   Edit1: TEdit;
   FloatSpinEdit1: TFloatSpinEdit;
   Label1: TLabel;
   Label2: TLabel;
   ListBox1: TListBox;
   ListBox2: TListBox;
   Panel1: TPanel;
   Panel2: TPanel;
   Panel3: TPanel;
   SpinEdit1: TSpinEdit;
   Splitter1: TSplitter;
   procedure Button1Click(Sender: TObject);
   procedure Button2Click(Sender: TObject);
   procedure Edit1Change(Sender: TObject);
   procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
   procedure FloatSpinEdit1Change(Sender: TObject);
   procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
   procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
   procedure ListBox1Click(Sender: TObject);
   procedure ListBox1DblClick(Sender: TObject);
   procedure ListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
   procedure ListBox2Click(Sender: TObject);
   procedure ListBox2DblClick(Sender: TObject);
   procedure SpinEdit1Change(Sender: TObject);
  private
    { private declarations }
   title: TSubTitleList;
   lastspeed: double;
  public
    { public declarations }
    datapoints: array of record
      measured, real: double;
    end;
   procedure setSubTitles(t: TSubTitleList);
  end;

var
  Form2: TForm2; 

implementation


{$R *.lfm}

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
begin
  title.offsetMs:=SpinEdit1.Value;
  title.scale:=FloatSpinEdit1.Value;
  Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  title.offsetMs:=SpinEdit1.Value;
  title.scale:=FloatSpinEdit1.Value;
end;

procedure TForm2.Edit1Change(Sender: TObject);
var
 i: Integer;
begin
  i := listbox1.ItemIndex;
  if i < 0 then i:=0;
  for i:=i to ListBox1.Count-1 do
    if pos(edit1.text, ListBox1.Items[i]) > 0  then begin
      ListBox1.ItemIndex:=i;
      exit;
    end;
  for i:=0 to ListBox1.ItemIndex do
    if pos(edit1.text, ListBox1.Items[i]) > 0  then begin
      ListBox1.ItemIndex:=i;
      exit;
    end;

end;

procedure TForm2.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
 i: Integer;
begin
  if key = VK_RETURN then begin
    for i:=listbox1.ItemIndex+1 to ListBox1.Count-1 do
      if pos(edit1.text, ListBox1.Items[i]) > 0  then begin
        ListBox1.ItemIndex:=i;
        exit;
      end;
    for i:=0 to ListBox1.ItemIndex do
      if pos(edit1.text, ListBox1.Items[i]) > 0  then begin
        ListBox1.ItemIndex:=i;
        exit;
      end;
  end;
end;

procedure TForm2.FloatSpinEdit1Change(Sender: TObject);
begin
//  SpinEdit1.Value:=round(SpinEdit1.Value / lastspeed * FloatSpinEdit1.Value);
  SpinEdit1Change(SpinEdit1);
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caHide;
end;

procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin

end;

procedure TForm2.ListBox1Click(Sender: TObject);
begin

end;

procedure TForm2.ListBox1DblClick(Sender: TObject);

var
 i: Integer;
 crossvariance, variance: Extended;
 meanmeasured, meanreal: extended;
begin
  i := ListBox1.ItemIndex;
  if i = -1 then exit;
  if not usedatapoints.Checked then begin
    SpinEdit1.Value:= round((title.titles[i].fromtime  + (-now + title.hiddenOffset)* title.scale)*24*60*60*1000);
  end else begin
    setlength(datapoints,length(datapoints)+1);
    datapoints[high(datapoints)].measured := now - title.hiddenOffset ;
    datapoints[high(datapoints)].real:=title.titles[i].fromtime;
    ListBox2.Items.add(FloatToStr(datapoints[high(datapoints)].measured)+':'+FloatToStr(datapoints[high(datapoints)].real));

    meanmeasured := 0;
    meanreal := 0;
    for i:=0 to high(datapoints) do begin
      meanmeasured+=datapoints[i].measured;
      meanreal+=datapoints[i].real;
    end;
    meanmeasured/=length(datapoints);
    meanreal/=length(datapoints);

    if length(datapoints) > 1 then begin

      crossvariance := 0.0;
      variance:=0.0;
      for i:=0 to high(datapoints) do begin
        crossvariance+=(datapoints[i].real-meanreal)*(datapoints[i].measured-meanmeasured);
        variance+=sqr(datapoints[i].measured - meanmeasured);
      end;

      FloatSpinEdit1.Value:=crossvariance/variance;
    end;

    SpinEdit1.Value:= round((meanreal  - meanmeasured* FloatSpinEdit1.Value)*24*60*60*1000)
  end;
  SpinEdit1Change(SpinEdit1);
end;

procedure TForm2.ListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin

end;

procedure TForm2.ListBox2Click(Sender: TObject);
begin

end;

procedure TForm2.ListBox2DblClick(Sender: TObject);
begin
  if ListBox2.ItemIndex<0 then exit;
  if listbox2.ItemIndex = high(datapoints) then setlength(datapoints, high(datapoints))
  else begin
    move(datapoints[listbox2.ItemIndex+1], datapoints[listbox2.ItemIndex], (high(datapoints) - listbox2.ItemIndex) * sizeof(datapoints[0]));
  end;
  ListBox2.Items.Delete(listbox2.ItemIndex);
end;

procedure TForm2.SpinEdit1Change(Sender: TObject);
begin
  if CheckBox1.Checked then Button2.Click;
end;

procedure TForm2.setSubTitles(t: TSubTitleList);
var i:integer;
begin
  title := t;
  SpinEdit1.Value:=round(t.offsetMs);
  FloatSpinEdit1.Value := title.scale;
  lastspeed:=title.scale;
  ListBox1.Clear;
  for i:=0 to high(t.titles) do
    ListBox1.Items.Add(t.titles[i].text);
end;

end.

