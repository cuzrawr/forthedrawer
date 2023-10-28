CC = cc
CFLAGS = -Wall -Werror -O3 -ffunction-sections -fdata-sections -flto -funroll-loops -finline-functions -fomit-frame-pointer -ffast-math -pipe -fno-plt -fexceptions

LDFLAGS = -lwinmm -mwindows

TARGET = keyboardtypo
SRC = keyboardtypo.c
OBJ = keyboardtypo.o ss_ui_type.o

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	strip -s $@.exe

keyboardtypo.o: keyboardtypo.c ss_ui_type.o
	$(CC) $(CFLAGS) -c $< -o $@

ss_ui_type.o: ss_ui_type.rc
	windres.exe -J rc -O coff $< -o $@

clean:
	rm -f $(OBJ) $(TARGET)
