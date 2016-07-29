unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,unit2, ExtCtrls, RzPanel;

type
  TForm1 = class(TForm)
    RzPanel1: TRzPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  self.rzpanel1.caption:=(DiskSerialNo);
end;

end.
