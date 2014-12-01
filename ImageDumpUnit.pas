unit ImageDumpUnit;

interface

{
  Author: Andrea Magni (Wintech-Italia s.r.l.)
  Contacts:
    Twitter: @andreamagni82
    Facebook: https://www.facebook.com/andreamagni82
    Google+: https://plus.google.com/+AndreaMagni
    Blog: blog.delphiedintorni.it
}

uses
  System.Classes, System.SysUtils
  , FMX.Types, FMX.Forms, FMX.Objects;

function ForEachObject(const AParent: TFmxObject; ADoSomething: TProc<TFmxObject, string>; APath: string = '') : Integer;
function SaveAllImagesToDisk(AForm: TForm): Integer;
function LoadAllImagesFromDisk(AForm: TForm): Integer;

implementation

uses
  IOUtils;

function ForEachObject(const AParent: TFmxObject; ADoSomething: TProc<TFmxObject, string>; APath: string = '') : Integer;
var
  LChild: TFmxObject;
  LPath: string;
begin
  Result := 0;
  LPath := APath;
  if LPath <> '' then
    LPath := LPath + '_';

  if AParent.ChildrenCount > 0 then
    for LChild in AParent.Children do
    begin
      ADoSomething( LChild, LPath + LChild.Name );
      Inc( Result );

      Result := Result + ForEachObject( LChild, ADoSomething, LPath + LChild.Name );
    end;
end;

function GetBasePath(AForm: TForm): string;
begin
  {$IFDEF MSWINDOWS}
  Result := ExtractFilePath(ParamStr(0)) + '\images_dump\' + AForm.Name;
  {$ELSE}
  Result := TPath.GetDocumentsPath + '/images_dump/' + AForm.Name;
  {$ENDIF}
end;

function SaveAllImagesToDisk(AForm: TForm): Integer;
var
  LImages: Integer;
  LBasePath: string;
begin
  LBasePath := GetBasePath(AForm);
  ForceDirectories(LBasePath);

  LImages := 0;
  ForEachObject(AForm,
    procedure (AObj: TFmxObject; AName: string)
    begin
      if (AObj is TImage) then
      begin
        Inc(LImages);
        TImage(AObj).Bitmap.SaveToFile(LBasePath+ '\' + AObj.Name + '.png');
      end;
    end);

  Result := LImages;
end;

function LoadAllImagesFromDisk(AForm: TForm): Integer;
var
  LBasePath: string;
  LFileName: string;
  LImage: TComponent;
  LComponentName: string;
begin
  Result := 0;

  LBasePath := GetBasePath(AForm);
  if not TDirectory.Exists(LBasePath) then
    raise Exception.CreateFmt('No image dump folder found for %s', [AForm.Name]);

  for LFileName in TDirectory.GetFiles(LBasePath) do
  begin
    LComponentName := ChangeFileExt(TPath.GetFileName(LFileName), '');
    LImage := AForm.FindComponent(LComponentName);

    if Assigned(LImage) and (LImage is TImage) then
    begin
      TImage(LImage).Bitmap.LoadFromFile(LFileName);
      Inc(Result);
    end;
  end;
end;

end.
