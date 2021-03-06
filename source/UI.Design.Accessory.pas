unit UI.Design.Accessory;

interface

uses
  UI.Base,
  System.TypInfo,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Colors, UI.Standard;

type
  TAccessoryDesigner = class(TForm)
    Layout1: TLayout;
    Button2: TButton;
    btnOk: TButton;
    Line1: TLine;
    ComboColorBox1: TComboColorBox;
    Label1: TLabel;
    VertScrollView1: TVertScrollView;
    BodyView: TGridsLayout;
    TextView1: TTextView;
    procedure Button2Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboColorBox1Change(Sender: TObject);
    procedure VertScrollView1Painting(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
  private
    { Private declarations }
    FAccessory: TViewAccessory;
    FChangeing: Boolean;
    FCheckboardBitmap: TBitmap;

    procedure SetAccessory(const Value: TViewAccessory);
    procedure DoClickItem(Sender: TObject);
    procedure DoDbClickItem(Sender: TObject);
    procedure PrepareCheckboardBitmap;
  public
    { Public declarations }
    property Accessory: TViewAccessory read FAccessory write SetAccessory;
  end;

var
  AccessoryDesigner: TAccessoryDesigner;

implementation

{$R *.fmx}

procedure TAccessoryDesigner.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TAccessoryDesigner.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TAccessoryDesigner.ComboColorBox1Change(Sender: TObject);
var
  I: Integer;
begin
  if FChangeing then
    Exit;
  FChangeing := True;
  FAccessory.Color := ComboColorBox1.Color;
  FChangeing := False;

  BodyView.BeginUpdate;
  try
    for I := 0 to BodyView.ControlsCount - 1 do begin
      if BodyView.Controls[I] is TTextView then begin
        TViewBrush(TTextView(BodyView.Controls[I]).Drawable.ItemDefault).Accessory.Color := FAccessory.Color;
        //TTextView(BodyView.Controls[I]).Invalidate;
      end;
    end;
  finally
    BodyView.EndUpdate;
    BodyView.Invalidate;
  end;
end;

procedure TAccessoryDesigner.DoClickItem(Sender: TObject);
begin
  TTextView(Sender).Checked := True;
  FAccessory.Accessory := TViewAccessoryType(TTextView(Sender).Tag);
end;

procedure TAccessoryDesigner.DoDbClickItem(Sender: TObject);
begin
  DoClickItem(Sender);
  ModalResult := mrOk;
end;

procedure TAccessoryDesigner.FormCreate(Sender: TObject);
begin
  FAccessory := TViewAccessory.Create;
end;

procedure TAccessoryDesigner.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FAccessory);
  FreeAndNil(FCheckboardBitmap);
end;

procedure TAccessoryDesigner.FormShow(Sender: TObject);
var
  I: Integer;
  Item: TTextView;
begin
  TextView1.Visible := False;
  FChangeing := True;
  ComboColorBox1.Color := FAccessory.Color;
  FChangeing := False;
  TViewBrush(TextView1.Drawable.ItemDefault).Accessory.Color := FAccessory.Color;

  BodyView.BeginUpdate;
  try
    for I := 0 to Ord(High(TViewAccessoryType)) do begin
      Item := TTextView.Create(Self);
      Item.Name := '';
      Item.Tag := I;
      Item.Clickable := True;
      Item.Background := TextView1.Background;
      Item.Drawable := TextView1.Drawable;
      Item.Padding := TextView1.Padding;
      TViewBrush(Item.Drawable.ItemDefault).Accessory.Accessory := TViewAccessoryType(I);
      Item.GroupIndex := 1;
      Item.Gravity := TextView1.Gravity;
      Item.TextSettings := TextView1.TextSettings;
      Item.Text := GetEnumName(TypeInfo(TViewAccessoryType), I);
      Item.Parent := BodyView;
      Item.OnClick := DoClickItem;
      Item.OnDblClick := DoDbClickItem;
    end;
  finally
    BodyView.EndUpdate;
    BodyView.RecalcSize;
    VertScrollView1.RecalcUpdateRect;
    VertScrollView1.RecalcSize;
  end;
end;

procedure TAccessoryDesigner.PrepareCheckboardBitmap;
var
  i, j: Integer;
  M: TBitmapData;
begin
  if not Assigned(FCheckboardBitmap) then
  begin
    FCheckboardBitmap := TBitmap.Create(32, 32);
    if FCheckboardBitmap.Map(TMapAccess.Write, M) then
    try
      for j := 0 to FCheckboardBitmap.Height - 1 do
      begin
        for i := 0 to FCheckboardBitmap.Width - 1 do
        begin
          if odd(i div 8) and not odd(j div 8) then
            M.SetPixel(i, j, $FFE0E0E0)
          else if not odd(i div 8) and odd(j div 8) then
            M.SetPixel(i, j, $FFE0E0E0)
          else
            M.SetPixel(i, j, $FFFFFFFF)
        end;
      end;
    finally
      FCheckboardBitmap.Unmap(M);
    end;
  end;
end;

procedure TAccessoryDesigner.SetAccessory(const Value: TViewAccessory);
begin
  if Value = nil then
    Exit;
  FAccessory.Assign(Value);
  FAccessory.Style := TViewAccessoryStyle.Accessory;
end;

procedure TAccessoryDesigner.VertScrollView1Painting(Sender: TObject;
  Canvas: TCanvas; const ARect: TRectF);
begin
  PrepareCheckboardBitmap;
  Canvas.Fill.Kind := TBrushKind.Bitmap;
  Canvas.Fill.Bitmap.Bitmap := FCheckboardBitmap;
  Canvas.FillRect(ARect, 0, 0, [], 1);
end;

end.
