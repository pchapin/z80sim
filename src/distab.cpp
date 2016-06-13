/****************************************************************************
FILE          : distab.c
LAST REVISION : 2003-10-12
SUBJECT       : Tables used by the disassembly and simulation processes.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#include "distab.hpp"

char *disasm_strs[]={
  "NOP",              /* 0x00 */
  "LD    BC,w",
  "LD    (BC),A",
  "INC   BC",
  "INC   B",
  "DEC   B",
  "LD    B,b",
  "RLCA",
  
  "EX    AF,AF'",     /* 0x08 */
  "ADD   HL,BC",
  "LD    A,(BC)",
  "DEC   BC",
  "INC   C",
  "DEC   C",
  "LD    C,b",
  "RRCA",
  
  "DJNZ  o",          /* 0x10 */
  "LD    DE,w",
  "LD    (DE),A",
  "INC   DE",
  "INC   D",
  "DEC   D",
  "LD    D,b",
  "RLA",
  
  "JR    o",          /* 0x18 */
  "ADD   HL,DE",
  "LD    A,(DE)",
  "DEC   DE",
  "INC   E",
  "DEC   E",
  "LD    E,b",
  "RRA",
  
  "JR    NZ,o",       /* 0x20 */
  "LD    HL,w",
  "LD    (w),HL",
  "INC   HL",
  "INC   H",
  "DEC   H",
  "LD    H,b",
  "DAA",
  
  "JR    Z,o",        /* 0x28 */
  "ADD   HL,HL",
  "LD    HL,(w)",
  "DEC   HL",
  "INC   L",
  "DEC   L",
  "LD    L,b",
  "CPL",
  
  "JR    NC,o",       /* 0x30 */
  "LD    SP,w",
  "LD    (w),A",
  "INC   SP",
  "INC   (HL)",
  "DEC   (HL)",
  "LD    (HL),b",
  "SCF",
  
  "JR    C,o",        /* 0x38 */
  "ADD   HL,SP",
  "LD    A,(w)",
  "DEC   SP",
  "INC   A",
  "DEC   A",
  "LD    A,b",
  "CCF",
  
  "LD    B,B",        /* 0x40 */
  "LD    B,C",
  "LD    B,D",
  "LD    B,E",
  "LD    B,H",
  "LD    B,L",
  "LD    B,(HL)",
  "LD    B,A",
  
  "LD    C,B",        /* 0x48 */
  "LD    C,C",
  "LD    C,D",
  "LD    C,E",
  "LD    C,H",
  "LD    C,L",
  "LD    C,(HL)",
  "LD    C,A",
  
  "LD    D,B",        /* 0x50 */
  "LD    D,C",
  "LD    D,D",
  "LD    D,E",
  "LD    D,H",
  "LD    D,L",
  "LD    D,(HL)",
  "LD    D,A",
  
  "LD    E,B",        /* 0x58 */
  "LD    E,C",
  "LD    E,D",
  "LD    E,E",
  "LD    E,H",
  "LD    E,L",
  "LD    E,(HL)",
  "LD    E,A",
  
  "LD    H,B",        /* 0x60 */
  "LD    H,C",
  "LD    H,D",
  "LD    H,E",
  "LD    H,H",
  "LD    H,L",
  "LD    H,(HL)",
  "LD    H,A",
  
  "LD    L,B",        /* 0x68 */
  "LD    L,C",
  "LD    L,D",
  "LD    L,E",
  "LD    L,H",
  "LD    L,L",
  "LD    L,(HL)",
  "LD    L,A",
  
  "LD    (HL),B",     /* 0x70 */
  "LD    (HL),C",
  "LD    (HL),D",
  "LD    (HL),E",
  "LD    (HL),H",
  "LD    (HL),L",
  "HALT",
  "LD    (HL),A",
  
  "LD    A,B",        /* 0x78 */
  "LD    A,C",
  "LD    A,D",
  "LD    A,E",
  "LD    A,H",
  "LD    A,L",
  "LD    A,(HL)",
  "LD    A,A",
  
  "ADD   A,B",        /* 0x80 */
  "ADD   A,C",
  "ADD   A,D",
  "ADD   A,E",
  "ADD   A,H",
  "ADD   A,L",
  "ADD   A,(HL)",
  "ADD   A,A",
  
  "ADC   A,B",        /* 0x88 */
  "ADC   A,C",
  "ADC   A,D",
  "ADC   A,E",
  "ADC   A,H",
  "ADC   A,L",
  "ADC   A,(HL)",
  "ADC   A,A",
  
  "SUB   B",          /* 0x90 */
  "SUB   C",
  "SUB   D",
  "SUB   E",
  "SUB   H",
  "SUB   L",
  "SUB   (HL)",
  "SUB   A",
  
  "SBC   A,B",        /* 0x98 */
  "SBC   A,C",
  "SBC   A,D",
  "SBC   A,E",
  "SBC   A,H",
  "SBC   A,L",
  "SBC   A,(HL)",
  "SBC   A,A",
  
  "AND   B",          /* 0xA0 */
  "AND   C",
  "AND   D",
  "AND   E",
  "AND   H",
  "AND   L",
  "AND   (HL)",
  "AND   A",
  
  "XOR   B",          /* 0xA8 */
  "XOR   C",
  "XOR   D",
  "XOR   E",
  "XOR   H",
  "XOR   L",
  "XOR   (HL)",
  "XOR   A",
  
  "OR    B",          /* 0xB0 */
  "OR    C",
  "OR    D",
  "OR    E",
  "OR    H",
  "OR    L",
  "OR    (HL)",
  "OR    A",
  
  "CP    B",          /* 0xB8 */
  "CP    C",
  "CP    D",
  "CP    E",
  "CP    H",
  "CP    L",
  "CP    (HL)",
  "CP    A",
  
  "RET   NZ",         /* 0xC0 */
  "POP   BC",
  "JP    NZ,w",
  "JP    w",
  "CALL  NZ,w",
  "PUSH  BC",
  "ADD   A,b",
  "RST   00H",
  
  "RET   Z",          /* 0xC8 */
  "RET",
  "JP    Z,w",
  "DB    0CBH",
  "CALL  Z,w",
  "CALL  w",
  "ADC   A,b",
  "RST   08H",
  
  "RET   NC",         /* 0xD0 */
  "POP   DE",
  "JP    NC,w",
  "OUT   (b),A",
  "CALL  NC,w",
  "PUSH  DE",
  "SUB   b",
  "RST   10H",
  
  "RET   C",          /* 0xD8 */
  "EXX",
  "JP    C,w",
  "IN    A,(b)",
  "CALL  C,w",
  "DB    0DDH",
  "SBC   A,b",
  "RST   18H",
  
  "RET   PO",         /* 0xE0 */
  "POP   HL",
  "JP    PO,w",
  "EX    (SP),HL",
  "CALL  PO,w",
  "PUSH  HL",
  "AND   b",
  "RST   20H",
  
  "RET   PE",         /* 0xE8 */
  "JP    (HL)",
  "JP    PE,w",
  "EX    DE,HL",
  "CALL  PE,w",
  "DB    0EDH",
  "XOR   b",
  "RST   28H",
  
  "RET   P",          /* 0xF0 */
  "POP   AF",
  "JP    P,w",
  "DI",
  "CALL  P,w",
  "PUSH  AF",
  "OR    b",
  "RST   30H",
  
  "RET   M",          /* 0xF8 */
  "LD    SP,HL",
  "JP    M,w",
  "EI",
  "CALL  M,w",
  "DB    0FDH",
  "CP    b",
  "RST   38H"
  };
  
