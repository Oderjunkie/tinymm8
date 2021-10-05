struct Object { // https://gbdev.io/pandocs/OAM.html
    u8 ypos;    // Byte 0 - Y Position + 16
    u8 xpos;    // Byte 1 - X Position + 8
    u8 tile;    // Byte 2 - Tile Index
                // Byte 3 - Attributes/Flags
    u3 cgbpal;  //    Bit2-0 Palette number **CGB Mode Only** (OBP0-7)
    u1 bank;    //    Bit3   Tile VRAM-Bank **CGB Mode Only** (0=Bank 0, 1=Bank 1)
    u1 dmgpal;  //    Bit4   Palette number **Non CGB Mode Only** (0=OBP0, 1=OBP1)
    u1 xFlip;   //    Bit5   X flip (0=Normal, 1=Horizontlaly mirrored)
    u1 yFlip;   //    Bit6   Y flip (0=Normal, 1=Vertically mirrored)
    u1 underBG; //    Bit7   BG and Window over OBJ (0=No, 1=BG and Window colors 1-3 over the OBJ)
}

Object[40] sprite = *0xFE00;
