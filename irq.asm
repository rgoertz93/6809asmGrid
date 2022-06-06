* Example of setting up an IRQ to run in the background of your own machine language program
    ORG     $0E00
* Choose the VSYNC frequency
PAL         EQU  50 * PAL region uses 50hz for VSYNC
NTSC        EQU  60 * NTSC region uses 60hz for VSYNC
VSYNCFreq   EQU  NTSC * Change this to either NTSC or PAL depending on your region
* Clock related pointers
Jiffy       FCB  $00 * Used for the clock, counts down from 50 or 60, every time VSYNC IRQ is entered.  When it hit's zero a second has passed
Minutes1    FCB  $00 * Keep track of minutes
Minutes2    FCB  $00 * ""
Seconds1    FCB  $00 * Keep track of seconds
Seconds2    FCB  $00 * ""
* This is the actual IRQ routine
* When the IRQ is triggered all the registers are pushed onto the stack and saved automatically.
* Including the Program Counter (PC) it's like this command is done for you PSHS D,X,Y,U,CC,DP,PC
*
* NOTE: If you are using the FIRQ is for "Fast" interrupts the CPU does not push the registers onto the stack except for the CC and PC
*       You must take care and backup and restore any registers you change in your FIRQ routine.
*********************************
IRQ_Start:
    LDA     $FF02       * Acknowledge the VSYNC IRQ, this makes the IRQ happen again.  Since it's at the start of the IRQ here
                        * it's possible for another IRQ trigger to happen while we are still doing this routine.
                        * If you want to be sure that your IRQ isn't triggered again until you are finished this IRQ then
                        * place this instruction just before the RTI at the end of your IRQ
                        * We are fine here as this IRQ code is very short and will complete in less then 1/60 of a second.
    DEC     Jiffy       * countdown 1/50 (PAL) or 1/60 (NTSC) of a second
    BNE     IRQ_End     * Only continue after counting down to zero from 50 (PAL) or 60 (NTSC), VSYNC runs at 50 or 60Hz
* If not zero then exit the IRQ routine
* If we get here then Jiffy is now at zero so another second has passed so let's update the screen
    LDA     #VSYNCFreq  * Reset Jiffy
    STA     Jiffy       * to 50 (PAL) or 60 (NTSC)
    LDA     Seconds2    * check the ones value of the # of seconds
    CMPA    #$39        * if it is a nine then make it a zero
    BEQ     >           * make it a zero and add to the tens value of the # of seconds
    INCA                * Otherwise update
    STA     Seconds2    * Save
    BRA     Update      * Go copy the data to the screen
!   LDA     #$30        * set the ones value to zero
    STA     Seconds2    * Save it
    LDA     Seconds1    * Get the tens value of the seconds
    CMPA    #$35        * check if it is a 5
    BEQ     >           * If so then add one to minute value
    INCA                * otherwise add 1 to the tens value of the seconds
    STA     Seconds1    * save it
    BRA     Update      * Go copy the data to the screen
!   LDA     #$30        * Set the tens value of the seconds
    STA     Seconds1    * to a zero
    LDA     Minutes2    * Get the ones value of the minutes
    CMPA    #$39        * check if it is a nine
    BEQ     >           * if so then go add one to the tens of the minute value
    INCA                * otherwise increment the ones value of the seconds
    STA     Minutes2    * update the value
    BRA     Update      * Go copy the data to the screen
!   LDA     #$30        * Set the ones value of the minutes
    STA     Minutes2    * to zero
    INC     Minutes1    * add one to the tens value of the minutes
* Update the screen
Update:
    LDD    Minutes1     * Get the minutes value from RAM
    STD    $400         * Show it on the top left of the screen
    LDA    #':          * A now equals the value for a Colon
    STA    $402         * Display the Colon on the screen between the minutes and seconds
    LDD    Seconds1     * Get the seconds value from RAM
    STD    $403         * Show it on the top left of the screen
* All done the IRQ so we can now leave...
* Leaving an IRQ will automatically do a PULS D,X,Y,U,CC,DP,PC so that all registers are restored
*
* NOTE: If you are leaving an FIRQ which is "Fast" it does not restore all the registers it only restores the CC and the PC.
*       You must make sure you save and restore any registers you modify in your routine.
*********************************
IRQ_End:
    RTI
* Program starts here when BASIC EXEC command is used after LOADMing the program
* This section disables the HSYNC IRQ and enables the VSYNC IRQ
START:
    ORCC    #$50    * = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    LDA     $FF01   * PIA 0 side A control reg - PIA0AC
    ANDA    #$FE    * Clear bit 0 - HSYNC IRQ Disabled
    STA     $FF01   * Save settings
    *LDA     $FF00   * PIA 0 side A data register - PIA0AD
    LDA     $FF03   * PIA 0 side B control reg - PIA0BC
    ORA     #$01    * VSYNC IRQ enabled
    STA     $FF03   * Save Settings
    LDA     $FF02   * PIA 0 side B data register - PIA0BD We need to either CLR  $FF02, TST  $FF02 or LDA,LDB  $FF02 to activate the IRQ now and every time inside the IRQ too.
                    * I use LDA because it is only 2 CPU cycles. "Acknowledge the VSYNC IRQ"
*********************************
* Setup Vectored IRQ using VSYNC
*********************************
    LDA     #$7E        * Jump instruction Opcode
    STA     $10C        * Store it at IRQ jump address 
    LDX     #IRQ_Start  * Load X with the pointer value of our IRQ routine
    STX     $10D        * Store the new IRQ address location
* This is the counter display related code - Initialize the clock to 00:00
    LDD     #$3030      * ascii '00'
    STD     Minutes1    * Start showing 00 minutes
    STD     Seconds1    * Start showing 00 seconds
    LDB     #VSYNCFreq  * VSYNC is triggered 50 or 60 times a second
    STB     Jiffy       * store it

* This is where we enable the IRQ so the CPU will use it 
    ANDCC   #$EF        * = %11101111 this will Enable the IRQ to start
    LDA     $FF02       * PIA 0 side B data register - PIA0BD We need to either CLR  $FF02, TST  $FF02 or LDA,LDB  $FF02 to activate the IRQ now and every time inside the IRQ too.
                        * I use LDA because it is only 2 CPU cycles. "Acknowledge the VSYNC IRQ"

*
* Your program code goes here and the little clock IRQ will run in the background without any effect from the code below.
*********************************
* Little demo code to show the IRQ is running in the background
BigLoop:
    LDU     #$A000      * Show junk on the screen data copied from ROM
MidLoop:
    LDX     #$406       * Point X beside clock on screen
!   LDA     ,X+         * Get value in move X to the right
    STA     -2,X        * Store the value to left of where it was read from
    CMPX    #$600       * see if X is at the end of screen
    BNE     <           * if not keep going
    LDY     #$1000      * Delay
!   LEAY    -1,Y        * Delay countdown
    BNE     <           * Delay check if zero, if not loop
    LDA     ,U+         * get a byte from ROM
    ORA     #$80        * Make the value semi graphics characters
    STA     $5FF        * store it on screen
    CMPU    #$C000      * check if we are at the end of ROM
    BLO     MidLoop     * If not loop
    BRA     BigLoop     * Go start the process again...
    END    START        * Tell assembler when creating an ML program to set the 'EXEC' address to wherever the label START is in RAM (above)