class ZCL_CRC_16 definition
  public
  final
  create public .

public section.

  class-methods CRC16_MAP .
  class-methods CALC
    importing
      !I_PAYLOAD type STRING
    returning
      value(R_CRC16) type CHAR4 .
  class-methods CALC8
    importing
      !I_PAYLOAD type STRING
    returning
      value(R_CRC8) type CHAR2 .
  class-methods CRC8_MAP .
protected section.
PRIVATE SECTION.

  TYPES:
    ty_crcmap TYPE x LENGTH 4 .
  TYPES:
    tt_crcmap TYPE TABLE OF ty_crcmap WITH DEFAULT KEY .

  TYPES:
    ty_crcmap8 TYPE x LENGTH 2 .
  TYPES:
    tt_crcmap8 TYPE TABLE OF ty_crcmap8 WITH DEFAULT KEY .

  CLASS-DATA gt_crc16map TYPE tt_crcmap .
  CLASS-DATA gt_crc8map TYPE tt_crcmap8 .
ENDCLASS.



CLASS ZCL_CRC_16 IMPLEMENTATION.


METHOD calc.

  CONSTANTS: x0000ffff(4) TYPE x VALUE '0000FFFF',
             x00000000(4) TYPE x VALUE '00000000',
             x000000ff(4) TYPE x VALUE '000000FF',
             x000000(3)   TYPE x VALUE '000000'.

  DATA: lv_xstring  TYPE xstring,

        i           TYPE i,
        lv_len      TYPE i,
        j           TYPE p LENGTH 16,

        hex_crc     TYPE x LENGTH 4 VALUE x0000ffff,
        hex_r       TYPE x LENGTH 4,
        hex_l       TYPE x LENGTH 4,
        hex_aux     TYPE x LENGTH 4.

  "To XSTRING
  lv_xstring = cl_bcs_convert=>string_to_xstring( i_payload ).
  lv_len = xstrlen( lv_xstring ).

  IF gt_crc16map IS INITIAL.
    crc16_map( ).
  ENDIF.

  DO lv_len TIMES.

    "Complete Hex of Caracter
    i = sy-index - 1.
    CONCATENATE  x000000 lv_xstring+i(1) INTO  hex_aux  IN BYTE MODE.

    "crc >> 8
    hex_r =  hex_crc.
    SHIFT hex_r BY 1 PLACES RIGHT IN BYTE MODE.

    "crc << 8
    hex_l =  hex_crc.
    SHIFT hex_l BY 1 PLACES LEFT IN BYTE MODE.

    "Get Index
    j = hex_aux = ( hex_aux BIT-XOR hex_r ) BIT-AND x000000ff.

    "Get poly crc (1021)
    ADD 1 TO j.
    READ TABLE gt_crc16map INTO hex_aux INDEX j.

    "Calc Caracter
    j = hex_crc = hex_aux BIT-XOR hex_l.

  ENDDO.

  hex_crc = ( hex_crc BIT-XOR x00000000 ) BIT-AND x0000ffff.

  r_crc16 = hex_crc+2.

ENDMETHOD.


METHOD CALC8.

  CONSTANTS: x0000(2) TYPE x VALUE '0000',
             x00ff(2) TYPE x VALUE '00FF',
             x00(1)   TYPE x VALUE '00'.

  DATA: lv_xstring  TYPE xstring,

        i           TYPE i,
        lv_len      TYPE i,
        j           TYPE p LENGTH 8,

        hex_crc     TYPE x LENGTH 2 VALUE x0000,"CRC8 Initial Value
        hex_r       TYPE x LENGTH 2,
        hex_l       TYPE x LENGTH 2,
        hex_aux     TYPE x LENGTH 2.

  "To XSTRING
  lv_xstring = cl_bcs_convert=>string_to_xstring( i_payload ).
  lv_len = xstrlen( lv_xstring ).

  IF gt_crc8map IS INITIAL.
    crc8_map( ).
  ENDIF.

  DO lv_len TIMES.

    "Complete Hex of Caracter
    i = sy-index - 1.
    CONCATENATE  x00 lv_xstring+i(1) INTO  hex_aux  IN BYTE MODE.

    "Re-use precalculated
    hex_r =  hex_crc.

    "Get Index
    j = hex_aux = ( hex_aux BIT-XOR hex_r ) BIT-AND x00ff.

    "Get poly crc 0x07
    ADD 1 TO j.
    READ TABLE gt_crc8map INTO hex_aux INDEX j.

    "Calc Caracter
    j = hex_crc = hex_aux BIT-XOR hex_l.

  ENDDO.

  r_crc8 = hex_crc+1.

ENDMETHOD.


METHOD crc16_map.

  DEFINE add_map.
    append &1 to gt_crc16map.
  END-OF-DEFINITION.


  add_map:
  '00000000', '00001021', '00002042', '00003063', '00004084', '000050A5',
  '000060C6', '000070E7', '00008108', '00009129', '0000A14A', '0000B16B',
  '0000C18C', '0000D1AD', '0000E1CE', '0000F1EF', '00001231', '00000210',
  '00003273', '00002252', '000052B5', '00004294', '000072F7', '000062D6',
  '00009339', '00008318', '0000B37B', '0000A35A', '0000D3BD', '0000C39C',
  '0000F3FF', '0000E3DE', '00002462', '00003443', '00000420', '00001401',
  '000064E6', '000074C7', '000044A4', '00005485', '0000A56A', '0000B54B',
  '00008528', '00009509', '0000E5EE', '0000F5CF', '0000C5AC', '0000D58D',
  '00003653', '00002672', '00001611', '00000630', '000076D7', '000066F6',
  '00005695', '000046B4', '0000B75B', '0000A77A', '00009719', '00008738',
  '0000F7DF', '0000E7FE', '0000D79D', '0000C7BC', '000048C4', '000058E5',
  '00006886', '000078A7', '00000840', '00001861', '00002802', '00003823',
  '0000C9CC', '0000D9ED', '0000E98E', '0000F9AF', '00008948', '00009969',
  '0000A90A', '0000B92B', '00005AF5', '00004AD4', '00007AB7', '00006A96',
  '00001A71', '00000A50', '00003A33', '00002A12', '0000DBFD', '0000CBDC',
  '0000FBBF', '0000EB9E', '00009B79', '00008B58', '0000BB3B', '0000AB1A',
  '00006CA6', '00007C87', '00004CE4', '00005CC5', '00002C22', '00003C03',
  '00000C60', '00001C41', '0000EDAE', '0000FD8F', '0000CDEC', '0000DDCD',
  '0000AD2A', '0000BD0B', '00008D68', '00009D49', '00007E97', '00006EB6',
  '00005ED5', '00004EF4', '00003E13', '00002E32', '00001E51', '00000E70',
  '0000FF9F', '0000EFBE', '0000DFDD', '0000CFFC', '0000BF1B', '0000AF3A',
  '00009F59', '00008F78', '00009188', '000081A9', '0000B1CA', '0000A1EB',
  '0000D10C', '0000C12D', '0000F14E', '0000E16F', '00001080', '000000A1',
  '000030C2', '000020E3', '00005004', '00004025', '00007046', '00006067',
  '000083B9', '00009398', '0000A3FB', '0000B3DA', '0000C33D', '0000D31C',
  '0000E37F', '0000F35E', '000002B1', '00001290', '000022F3', '000032D2',
  '00004235', '00005214', '00006277', '00007256', '0000B5EA', '0000A5CB',
  '000095A8', '00008589', '0000F56E', '0000E54F', '0000D52C', '0000C50D',
  '000034E2', '000024C3', '000014A0', '00000481', '00007466', '00006447',
  '00005424', '00004405', '0000A7DB', '0000B7FA', '00008799', '000097B8',
  '0000E75F', '0000F77E', '0000C71D', '0000D73C', '000026D3', '000036F2',
  '00000691', '000016B0', '00006657', '00007676', '00004615', '00005634',
  '0000D94C', '0000C96D', '0000F90E', '0000E92F', '000099C8', '000089E9',
  '0000B98A', '0000A9AB', '00005844', '00004865', '00007806', '00006827',
  '000018C0', '000008E1', '00003882', '000028A3', '0000CB7D', '0000DB5C',
  '0000EB3F', '0000FB1E', '00008BF9', '00009BD8', '0000ABBB', '0000BB9A',
  '00004A75', '00005A54', '00006A37', '00007A16', '00000AF1', '00001AD0',
  '00002AB3', '00003A92', '0000FD2E', '0000ED0F', '0000DD6C', '0000CD4D',
  '0000BDAA', '0000AD8B', '00009DE8', '00008DC9', '00007C26', '00006C07',
  '00005C64', '00004C45', '00003CA2', '00002C83', '00001CE0', '00000CC1',
  '0000EF1F', '0000FF3E', '0000CF5D', '0000DF7C', '0000AF9B', '0000BFBA',
  '00008FD9', '00009FF8', '00006E17', '00007E36', '00004E55', '00005E74',
  '00002E93', '00003EB2', '00000ED1', '00001EF0'." to GT_CRC16MAP.

ENDMETHOD.


METHOD CRC8_MAP.

  DEFINE add_map.
    append &1 to gt_crc8map.
  END-OF-DEFINITION.


  add_map:
  '0000', '0007', '000E', '0009', '001C', '001B', '0012', '0015',
  '0038', '003F', '0036', '0031', '0024', '0023', '002A', '002D',
  '0070', '0077', '007E', '0079', '006C', '006B', '0062', '0065',
  '0048', '004F', '0046', '0041', '0054', '0053', '005A', '005D',
  '00E0', '00E7', '00EE', '00E9', '00FC', '00FB', '00F2', '00F5',
  '00D8', '00DF', '00D6', '00D1', '00C4', '00C3', '00CA', '00CD',
  '0090', '0097', '009E', '0099', '008C', '008B', '0082', '0085',
  '00A8', '00AF', '00A6', '00A1', '00B4', '00B3', '00BA', '00BD',
  '00C7', '00C0', '00C9', '00CE', '00DB', '00DC', '00D5', '00D2',
  '00FF', '00F8', '00F1', '00F6', '00E3', '00E4', '00ED', '00EA',
  '00B7', '00B0', '00B9', '00BE', '00AB', '00AC', '00A5', '00A2',
  '008F', '0088', '0081', '0086', '0093', '0094', '009D', '009A',
  '0027', '0020', '0029', '002E', '003B', '003C', '0035', '0032',
  '001F', '0018', '0011', '0016', '0003', '0004', '000D', '000A',
  '0057', '0050', '0059', '005E', '004B', '004C', '0045', '0042',
  '006F', '0068', '0061', '0066', '0073', '0074', '007D', '007A',
  '0089', '008E', '0087', '0080', '0095', '0092', '009B', '009C',
  '00B1', '00B6', '00BF', '00B8', '00AD', '00AA', '00A3', '00A4',
  '00F9', '00FE', '00F7', '00F0', '00E5', '00E2', '00EB', '00EC',
  '00C1', '00C6', '00CF', '00C8', '00DD', '00DA', '00D3', '00D4',
  '0069', '006E', '0067', '0060', '0075', '0072', '007B', '007C',
  '0051', '0056', '005F', '0058', '004D', '004A', '0043', '0044',
  '0019', '001E', '0017', '0010', '0005', '0002', '000B', '000C',
  '0021', '0026', '002F', '0028', '003D', '003A', '0033', '0034',
  '004E', '0049', '0040', '0047', '0052', '0055', '005C', '005B',
  '0076', '0071', '0078', '007F', '006A', '006D', '0064', '0063',
  '003E', '0039', '0030', '0037', '0022', '0025', '002C', '002B',
  '0006', '0001', '0008', '000F', '001A', '001D', '0014', '0013',
  '00AE', '00A9', '00A0', '00A7', '00B2', '00B5', '00BC', '00BB',
  '0096', '0091', '0098', '009F', '008A', '008D', '0084', '0083',
  '00DE', '00D9', '00D0', '00D7', '00C2', '00C5', '00CC', '00CB',
  '00E6', '00E1', '00E8', '00EF', '00FA', '00FD', '00F4', '00F3'. "to GT_CRC8MAP
  "'00002E93', '00003EB2', '00000ED1', '00001EF0'." to GT_CRC8MAP.

ENDMETHOD.
ENDCLASS.
