#include "main.h"
#include "stm32mp1xx_hal.h"
#include "inttypes.h"
void main() {
	L1C_EnableCaches();
	L1C_EnableBTAC();
	L2C_Enable();
	// enable HSE (24MHz)
	RCC->OCENSETR |= RCC_OCENSETR_HSEON;
	while (!RCC->OCRDYR & RCC_OCRDYR_HSERDY);
	// Switch PLL1 clock source to HSE
	// default prescaler is 2 (12MHz)
	RCC->RCK12SELR |= 1;
	while (!RCC->RCK12SELR & RCC_RCK12SELR_PLL12SRCRDY);

	// set pll1 multiplication factor
	uint32_t DIVM1 = 2;
	uint32_t DIVN1 = 100;
	uint32_t DIVP1 = 0;
	RCC->PLL1CFGR1 = (DIVM1<<16) | DIVN1;
	RCC->PLL1CFGR2 = DIVP1;
	// set pll1 into integer mode
	RCC->PLL1FRACR |= RCC_PLL1FRACR_FRACLE;

	// turn pll1 on
	RCC->PLL1CR |= RCC_PLL1CR_PLLON;
	// wait for pll1 to be ready
	while (!RCC->PLL1CR & RCC_PLL1CR_PLL1RDY);

	// enable pll1_p_ck output
	RCC->PLL1CR |= RCC_PLL1CR_DIVPEN;


	// set pll2 multiplication factor
	RCC->PLL2CFGR1 = (1<<16) | 80;
	
	// set pll2 into integer mode
	RCC->PLL2FRACR |= RCC_PLL2FRACR_FRACLE;
	// turn pll1 on
	RCC->PLL2CR |= RCC_PLL2CR_PLLON;
	// wait for pll1 to be ready
	while (!RCC->PLL2CR & RCC_PLL2CR_PLL2RDY);

	// enable pll1_p_ck output
	RCC->PLL2CR |= RCC_PLL2CR_DIVPEN;



	// switch mpu clock to pll1_p_ck
	uint32_t MPUSRC = 0x2;
	RCC->MPCKSELR = MPUSRC;

	// switch axi clock to pll2_p_ck
	RCC->ASSCKSELR |= 0x2;

	__HAL_RCC_GPIOA_CLK_ENABLE();

	int tmp = GPIOA->MODER;
	tmp &= ~((0b10<<28)|(0b10<<22));
	GPIOA->MODER = tmp;

	int i;
	while(1){
		if (i++%0x10000 == 0) {
			GPIOA->ODR = (~(GPIOA->ODR)) & ((1<<14) | (1<<11));
		}
	}
}

