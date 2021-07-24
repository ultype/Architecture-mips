PROJECT := test0
EXEC = $(PROJECT).bin
DUMP = $(PROJECT).s 
TOOL = mips-linux-gnu-
CC = $(TOOL)gcc
DP = $(TOOL)objdump
RM = rm
src = $(wildcard *.c *.h)


LDFLAGS = -lm
CFLAGS = -std=gnu99 #-Wall -O0 -g3

$(info $(src))


OBJS := \
	test0.o \


all : $(DUMP)

$(DUMP) : $(EXEC) $(OBJS)
	$(DP) -Slz  $(EXEC) > testbin0.txt
	$(DP) -Slz  $(OBJS) > testobj0.txt

$(EXEC): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
	
clean:
	$(RM) -rf *.o *.bin *.txt
