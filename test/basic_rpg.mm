mod "incbin";
mod "gbapi";
void main() {
    gb::dma.src = &incbin!("basic_rpg_gfx.bin");
    gb::dma.dst = gb::tileData;
    gb::sprite[0].tile = gb::tileData[0][0];
    gb::sprite[0].DMGPal = 0;
    gb::sprite[0].CGBPal = 0;
    while (true) {
        if (gb::button.left)
	    gb::sprite[0].xpos--;
	if (gb::button.right)
	    gb::sprite[0].xpos++;
	if (gb::button.up)
	    gb::sprite[0].ypos--;
	if (gb::button.down)
	    gb::sprite[0].ypos++;
	gb::waitForVblank!();
    }
}
