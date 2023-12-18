/*
 * checkpoint.h
 *
 *  Created on: 2023¦~12¤ë14¤é
 *      Author: henry_esslab
 */

#ifndef CHECKPOINT_CHECKPOINT_H_
#define CHECKPOINT_CHECKPOINT_H_

#include <stdint.h>
#include <stdio.h>
#include "driverlib.h"
#pragma PERSISTENT(pc_ckt)
uint32_t pc_ckt = 0;
#pragma PERSISTENT(reg_checkpoint)
uint32_t reg_checkpoint[16] = {0};
#pragma PERSISTENT(sram_checkpoint)
uint8_t sram_checkpoint[4 * 1024] = {0};

/******************* define in checkpoint.asm ***************************/
void checkpoint_asm();
void restore_asm();
void shutdown_asm();
/************************************************************************/

/******************* define in linker file ******************************/
extern char __bss__;
extern char __bssEnd__;
extern char __stack__;
extern char __stackEnd__;
extern char __data__;
extern char __dataEnd__;
/************************************************************************/

// from https://git.cs.nctu.edu.tw/cs-esslab/myqtreesearch/-/blob/main/Demo/MSP430X_MSP430FR5969_LaunchPad_IAR_CCS/timing.c
void timer_init(){
    Timer_A_initContinuousModeParam initContParam = {0};
    initContParam.clockSource = TIMER_A_CLOCKSOURCE_SMCLK; // 8MHz
    initContParam.clockSourceDivider = TIMER_A_CLOCKSOURCE_DIVIDER_1; //granularity - no division : 1MHz
    initContParam.timerInterruptEnable_TAIE = TIMER_A_TAIE_INTERRUPT_ENABLE;
    initContParam.timerClear = TIMER_A_DO_CLEAR;
    initContParam.startTimer = false;
    Timer_A_initContinuousMode(TIMER_A1_BASE, &initContParam);
}

void timer_start(){
    printf("timer_start()\n");
    Timer_A_clear (TIMER_A1_BASE); // CLEAR the timer before starting
    Timer_A_startCounter(TIMER_A1_BASE, TIMER_A_CONTINUOUS_MODE);
}

uint16_t timer_end(){
    Timer_A_stop(TIMER_A1_BASE);
    uint16_t elapsed_time = Timer_A_getCounterValue(TIMER_A1_BASE);
    return elapsed_time;
}

void checkpoint(){
    printf("checkpoint()\n");
    timer_start();
    checkpoint_asm();
    printf("timer_end(): %u\n", timer_end());
}

void restore(){
    printf("restore()\n");
    timer_start();
    restore_asm();

    printf("it shouldn't be printed.\n");
}

void shutdown(){
    printf("shutdown()\n");
//    PMM_turnOffRegulator();
//    __bis_SR_register(LPM4_bits);
    shutdown_asm();
    printf("it shouldn't be printed.\n");
}

#endif /* SOURCE_CHECKPOINT_H_ */
