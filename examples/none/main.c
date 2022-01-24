#include "main.h"
#include "stm32mp1xx_hal.h"
#include "inttypes.h"
void main() {
	L1C_EnableCaches();
	L1C_EnableBTAC();
	// enable HSE (24MHz)
	RCC->OCENSETR |= RCC_OCENSETR_HSEON;
	while (!RCC->OCRDYR & RCC_OCRDYR_HSERDY);
	// Switch PLL1 clock source to HSE
	// default prescaler is 2 (12MHz)
	RCC->RCK12SELR |= 1;
	while (!RCC->RCK12SELR & RCC_RCK12SELR_PLL12SRCRDY);

	// HSE is 24MHz
	// set pll1 multiplication factor
	uint32_t DIVM1 = 1; // divide by 3 (8MHz)
	uint32_t DIVN1 = 99; // multiply by 100 (800MHz)
	uint32_t DIVP1 = 0; // no divisor
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


	////// pll2 configuration
	uint32_t DIVM2 = 1; // divide by 2 (12MHz)
	uint32_t DIVN2 = 43; // multiply by 44 (528MHz)
	uint32_t DIVP2 = 1; // divide by 2 (264MHz)
	// set pll2 multiplication factor
	RCC->PLL2CFGR1 = (DIVM2<<16) | DIVN2;
	RCC->PLL2CFGR2 = DIVP2;
	// set pll2 into integer mode
	RCC->PLL2FRACR |= RCC_PLL2FRACR_FRACLE;
	// turn pll1 on
	RCC->PLL2CR |= RCC_PLL2CR_PLLON;
	// wait for pll1 to be ready
	while (!RCC->PLL2CR & RCC_PLL2CR_PLL2RDY);

	// enable pll2_p_ck output
	RCC->PLL2CR |= RCC_PLL2CR_DIVPEN;



	//////// pll3 configuration
	RCC->RCK3SELR |= 1; // select HSE as pll3 clock source
	uint32_t DIVM3 = 1; // divide by 2 (12MHz)
	uint32_t DIVN3 = 49; // multiply by 44 (528MHz)
	RCC->PLL3CFGR1 = (DIVM3<<16) | DIVN3;
	RCC->PLL3CFGR1 |= 1 << 24; // set IFRGE to x1

	RCC->PLL3CFGR2 |= 1;
	// set pll3 into integer mode
	RCC->PLL3FRACR |= RCC_PLL3FRACR_FRACLE;

	// turn pll3 on
	RCC->PLL3CR |= RCC_PLL3CR_PLLON;
	// wait for pll1 to be ready
	while (!RCC->PLL3CR & RCC_PLL3CR_PLL3RDY);
	// enable pll3_p_ck output
	RCC->PLL3CR |= RCC_PLL3CR_DIVPEN;

	// switch mpu clock to pll1_p_ck
	uint32_t MPUSRC = 0x2;
	RCC->MPCKSELR = MPUSRC;

	// switch axi clock to pll2_p_ck
	uint32_t AXISSRC = 0x2;
	RCC->ASSCKSELR = AXISSRC;

	RCC->APB1DIVR |= 1;
	while (!RCC->APB1DIVR & RCC_APB1DIVR_APB1DIVRDY);
	RCC->APB2DIVR |= 1;
	while (!RCC->APB2DIVR & RCC_APB2DIVR_APB2DIVRDY);
	RCC->APB3DIVR |= 1;
	while (!RCC->APB3DIVR & RCC_APB3DIVR_APB3DIVRDY);
	RCC->APB4DIVR |= 1;
	while (!RCC->APB4DIVR & RCC_APB4DIVR_APB4DIVRDY);
	RCC->APB5DIVR |= 2;
	while (!RCC->APB5DIVR & RCC_APB5DIVR_APB5DIVRDY);
	// switch mcu clock to pll3_p_ck
	uint32_t MCUSSRC = 0x3;
	RCC->MSSCKSELR = MCUSSRC;

	__HAL_RCC_GPIOA_CLK_ENABLE();

	int tmp = GPIOA->MODER;
	tmp &= ~((0b10<<28)|(0b10<<22));
	GPIOA->MODER = tmp;

	for(;;) {
		for(int i = 0; i < 0x10000; i++);
		GPIOA->ODR = (~(GPIOA->ODR)) & ((1<<14) | (1<<11));

	}

}

