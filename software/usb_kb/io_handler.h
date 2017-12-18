#ifndef IO_HANDLER_H_
#define IO_HANDLER_H_
#include "alt_types.h"

void IO_write(alt_u8 Address, alt_u16 Data);
alt_u16 IO_read(alt_u8 Address);
void IO_init(void);


#endif
