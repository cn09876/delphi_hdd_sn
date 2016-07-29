unit unit2;
interface

uses
  Windows, SysUtils;
type
  TIDERegs = packed record
    bFeaturesReg: Byte;
    bSectorCountReg: Byte;
    bSectorNumberReg: Byte;
    bCylLowReg: Byte;
    bCylHighReg: Byte;
    bDriveHeadReg: Byte;
    bCommandReg: Byte;
    bReserved: Byte;
  end;
 
  TSendCmdInParams = packed record
    cBufferSize: DWORD;
    irDriveRegs: TIDERegs;
    bDriveNumber: Byte;
    bReserved: array[0..2] of Byte;
    dwReserved: array[0..3] of DWORD;
    bBuffer: array[0..0] of Byte;
  end;
 
  PIdSector = ^TIdSector;
  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of Char;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: array[0..7] of Char;
    sModelNumber: array[0..39] of Char;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: DWORD;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: DWORD;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: array[0..127] of Byte;
  end;
 
  TDriverStatus = packed record
    bDriverError: Byte;
    bIDEStatus: Byte;
    bReserved: array[0..1] of Byte;
    dwReserved: array[0..1] of DWORD;
  end;
 
  TSendCmdOutParams = packed record
    cBufferSize: DWORD;
    DriverStatus: TDriverStatus;
    bBuffer: array[0..0] of Byte;
  end;

  function DiskSerialNo: string;

implementation

procedure ChangeByteOrder(var Data; Size: Integer);
var
  p: PChar;
  i: Integer;
  c: Char;
begin
  p := @Data;
  for i := 0 to (Size shr 1) - 1 do
  begin
    c := p^;
    p^ := (p + 1)^;
    (p + 1)^ := c;
    Inc(p, 2);
  end;
end;
 
function DiskSerialNo: string;
const
  IDENTIFY_BUFFER_SIZE = 512;
var
  hDevice: THandle;
  cbBytesReturned: DWORD;
  SCIP: TSendCmdInParams;
  aIdOutCmd: array[0..(SizeOf(TSendCmdOutParams) + IDENTIFY_BUFFER_SIZE - 1) - 1] of Byte;
  IdOutCmd: TSendCmdOutParams absolute aIdOutCmd;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    hDevice := CreateFile('\\.\PhysicalDrive0', GENERIC_READ or GENERIC_WRITE,
      FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0)
  else hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
  if hDevice = INVALID_HANDLE_VALUE then Exit;
  FillChar(SCIP, SizeOf(TSendCmdInParams) - 1, #0);
  FillChar(aIdOutCmd, SizeOf(aIdOutCmd), #0);
  cbBytesReturned := 0;
  SCIP.cBufferSize := IDENTIFY_BUFFER_SIZE;
  SCIP.irDriveRegs.bSectorCountReg := 1;
  SCIP.irDriveRegs.bSectorNumberReg := 1;
  SCIP.irDriveRegs.bDriveHeadReg := $A0;
  SCIP.irDriveRegs.bCommandReg := $EC;
  if DeviceIoControl(hDevice, $0007C088, @SCIP, SizeOf(TSendCmdInParams) - 1,
    @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil) then
  begin
    with PIdSector(@IdOutCmd.bBuffer)^ do
    begin
      ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber));
      (Pchar(@sSerialNumber) + SizeOf(sSerialNumber))^ := #0;
      Result := Pchar(@sSerialNumber);
    end;
  end;
  CloseHandle(hDevice);
end;



end.
