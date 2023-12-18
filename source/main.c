#include <stdio.h>
#include <msp430.h> 
#include "driverlib.h"
#include "checkpoint.h"

#pragma PERSISTENT(first_start)
int first_start = 1;
#pragma PERSISTENT(shutdown_test)
int shutdown_test = 3;

void task() {
    int i;
      for(i = 0 ; i <= 100; ++i){
          printf("i: %d\n", i);
          if(i == 10){
              checkpoint();
          }
          else if(i == 20 && shutdown_test == 3){
              shutdown_test--;
              shutdown();
              printf("it shouldn't be printed.\n");
          }
          else if(i == 30){
              checkpoint();
          }
          else if(i == 50 && shutdown_test == 2){
              shutdown_test--;
              shutdown();
              printf("it shouldn't be printed.\n");
          }
          else if(i == 80){
              checkpoint();
          }
          else if(i == 99 && shutdown_test == 1){
              shutdown_test--;
              shutdown();
              printf("it shouldn't be printed.\n");
          }
      }
}

int main(void) {
    WDTCTL = WDTPW | WDTHOLD;               // Stop WDT
    if(first_start){
        first_start = 0;
//        print_sram_backup();

//        print_reg_checkpoint();
//        task_checkpoint();
        task();
//        printf("__bss__: %lx\n", _symval(&__bss__));
    }
    else{
//        print_reg_checkpoint();
        restore();
    }

}
