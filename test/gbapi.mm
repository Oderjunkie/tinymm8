namespace gb {
    // https://gbdev.io/pandocs/OAM.html
    struct Object { // 8000 - OAM
        u8 yPos;    // Byte 0 - Y Position + 16
        u8 xPos;    // Byte 1 - X Position + 8
        u8 tile;    // Byte 2 - Tile Index
                    // Byte 3 - Attributes/Flags
        u1 underBG; //     Bit7   - BG and Window over OBJ - 0=No,     1=BG and Window colors 1-3 over the OBJ
        u1 yFlip;   //     Bit6   - Y flip                 - 0=Normal, 1=Vertically mirrored
        u1 xFlip;   //     Bit5   - X flip                 - 0=Normal, 1=Horizontlaly mirrored
        u1 DMGPal;  //     Bit4   - [DMG] Palette number   - 0=OBP0,   1=OBP1
        u1 bank;    //     Bit3   - [CGB] Tile VRAM-Bank   - 0=Bank 0, 1=Bank 1
        u3 CGBPal;  //     Bit0-2 - [CGB] Palette number   - OBP0-7
    };

    // https://gbdev.io/pandocs/LCDC.html
    struct LCDC {             // FF40 - LCDC (LCD Control) (R/W)
        u1 LCDEnable;         //     Bit 7 - LCD and PPU enable           - 0=Off,       1=On
        u1 winMapB;           //     Bit 6 - Window tile map area         - 0=9800-9BFF, 1=9C00-9FFF
        u1 winEnable;         //     Bit 5 - Window enable                - 0=Off,       1=On
        u1 tileHigh;          //     Bit 4 - BG and Window tile data area - 0=8800-97FF, 1=8000-8FFF
        u1 BGMapB;            //     Bit 3 - BG tile map area             - 0=9800-9BFF, 1=9C00-9FFF
        u1 OBJSize;           //     Bit 2 - OBJ size                     - 0=8x8,       1=8x16
        u1 OBJEnable;         //     Bit 1 - OBJ enable                   - 0=Off,       1=On
        union {
    	    u1 BGWinEnable;   //     Bit 0 - [DMG] BG and Window Enable   - 0=Off,       1=On
    	    u1 BGWinPriority; //     Bit 0 - [CGB] BG and Window Priority - 0=Off,       1=On
        };
    };

    // https://gbdev.io/pandocs/STAT.html
    struct STAT {         // FF41 - STAT (LCDS)
        const u1;         //     Bit 7   - always high (Read Only)                          - 0=Low,       1=High
              u1 LInt;    //     Bit 6   - LYC=LY STAT Interrupt source (Read/Write)        -              1=Enable
              u1 OInt;    //     Bit 5   - Mode 2 OAM STAT Interrupt source (Read/Write)    -              1=Enable
              u1 VInt;    //     Bit 4   - Mode 1 VBlank STAT Interrupt source (Read/Write) -              1=Enable
              u1 HInt;    //     Bit 3   - Mode 0 HBlank STAT Interrupt source (Read/Write) -              1=Enable
              u1 LYCFlag; //     Bit 2   - LYC=LY Flag (Read/Write)                         - 0=Different, 1=Equal
        const u2 mode;    //     Bit 1-0 - Mode Flag (Read Only)                            -              1=Enable
    };

    //
    struct RP {
	      u1 write;      //     Bit 0   - Write Data (R/W)       - 0=LED Off,             1=LED On
        const u1 read;       //     Bit 1   - Read Data (R)          - 0=Receiving IR Signal, 1=Normal
        const u4;            //     Bit 2-5 - [unused] (R)           - 0=Low,                 1=High
	      u2 readEnable; //     Bit 6-7 - Data Read Enable (R/W) - 0=Disable,             3=Enable
    }

    // https://gbdev.io/pandocs/CGB_Registers.html#lcd-vram-dma-transfers
    struct VDMATransfer {
        bendian writeonly u16 src;   // HDMA1 - New DMA Source, High      | HDMA2 - New DMA Source, Low (W)
	bendian writeonly u16 dst;   // HDMA3 - New DMA Destination, High | HDMA4 - New DMA Destination, Low (W)
	        writeonly u15 len;   // HDMA5 - New DMA Length / 0x10 (W)
	        writeonly u1 isHDMA; // HDMA5 - General Purpose DMA       - 0=General purpose, 1=HDMA (W)
    }

    struct CH1 {
                  u3 sweepSpeed;        // NR10        - Number of sweep shift (R/W)         - n=0-7
                  u1 sweepDir;          // NR10        - Sweep Increase/Decrease (R/W)       - 0=Addition, 1=Subtraction
                  u3 sweepTime;         // NR10        - Sweep Time (R/W)                    - 
            const u1;                   // NR10        - Unused (R)                          - 
        writeonly u6 soundLength;       // NR11        - Sound length data (W)               - t1=0-63
                  u2 duty;              // NR11        - Wave Pattern Duty (R/W)             - 0=12.5%, 1=25%, 2=50%, 3=75%
                  u3 envelopeSpeed;     // NR12        - Number of envelope sweep (R/W)      - n=0-7
                  u1 envelopeDir;       // NR12        - Envelope Direction (R/W)            - 0=Decrease, 1=Increase
                  u4 envelopeVolume;    // NR12        - Initial Volume of envelope (R/W)    - 0=No Sound
        writeonly u11 freq;             // NR13 / NR14 - Channel 1 Frequency (R/W)           - 
            const u3;                   // NR14        - Unused (R)                          - 
                  u1 counter;           // NR14        - Counter/Consecutive selection (R/W) - 1=Stop output when length in NR11 expires
        writeonly u1 initial;           // NR14        - Initial (R)                         - 1=Restart Sound
    }
    
    u8[16][128][3] tileData =   (0x8000 as u8***);         // 8000 -> 97FF Video RAM Tile Data
    u8[8][8] tileMapA =         (0x9800 as u8**);          // 9800 -> 9BFF Video RAM Tile Map A
    u8[8][8] tileMapB =         (0x9C00 as u8**);          // 9C00 -> 9FFF Video RAM Tile Map B
    void[512] eRam =            (0xA000 as void*);         // A000 -> BFFF External RAM
    void[256][2] wRam =         (0xC000 as void*);         // C000 -> CFFF Work RAM (Nonbanked)
                                                           // D000 -> DFFF Work RAM (Banked for CGB)
                                                           // E000 -> FDFF ECHO ram (not assigned)
    Object[40] sprite =         (0xFE00 as Object*);       // FE00 -> FE9F OAM
                                                           // FEA0 -> FEFF
                                                           // FF00 -> FF3F P1, SB, SC, DIV, TIMA, TMA, TAC, IF
    CH1 ch1 =                  *(0xFF10 as CH1*)           // FF10 -> FF14 Sound Controller CH1
	                                                   // FF15 -> FF15 Unused (not assigned)
    LCDC lcdc =                *(0xFF40 as LCDC*);         // FF40 -> FF40 LCD Control
    STAT stat =                *(0xFF41 as STAT*);         // FF41 -> FF41 lcd STATus
    u8 scy =                   *(0xFF42 as u8*);           // FF42 -> FF42 SCroll Y
    u8 scx =                   *(0xFF43 as u8*);           // FF43 -> FF43 SCroll X
    const u8 ly =              *(0xFF44 as u8*);           // FF44 -> FF44 Lcd Y coordinate
    u8 lyc =                   *(0xFF45 as u8*);           // FF45 -> FF45 LY Compare
    u8 dma =                   *(0xFF46 as u8*);           // FF46 -> FF46 DMA transfer and start address
    u2[4] bgp =                *(0xFF47 as u2**);          // FF47 -> FF47 BG Palette data
    u8 wy =                    *(0xFF4A as u8*);           // FF4A -> FF4A Window Y position
    u8 wx =                    *(0xFF4B as u8*);           // FF4B -> FF4B Window X position
                                                           // FF4C -> FF4C KEY0 (not assigned)
                                                           // FF4D -> FF4D KEY1 (not assigned)
                                                           // FF4E -> FF4E unused (not assigned lol)
    u8 vbk =                   *(0xFF4F as u8*);           // FF4F -> FF4F Vram BanK (CGB)
    u8 bank =                  *(0xFF50 as u8*);           // FF50 -> FF50 BANK
    VDMATransfer dma =         *(0xFF51 as VDMATransfer*); // FF51 -> FF55 Direct Memory Access
    RP rp =                    *(0xFF56 as RP*);           // FF56 -> FF56 infraRed communications Port (CGB)
}
