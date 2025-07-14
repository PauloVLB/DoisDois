CXX = g++
CC = gcc
CXXFLAGS = -std=c++17 -Wall -Wextra -D_XOPEN_SOURCE_EXTENDED
CFLAGS = -std=c99 -Wall -Wextra -D_XOPEN_SOURCE_EXTENDED

LIBS = -lncursesw -ltinfo

OBJS = DoisDois_i.o DoisDois.o

TARGET = DoisDois

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LIBS)

DoisDois_i.o: DoisDois_i.c DoisDois.h
	$(CC) $(CFLAGS) -c DoisDois_i.c

DoisDois.o: DoisDois.cpp DoisDois.h
	$(CXX) $(CXXFLAGS) -c DoisDois.cpp

clean:
	rm -f $(OBJS) $(TARGET)
	
run: $(TARGET)
	./$(TARGET)

.PHONY: all clean clean-win run
