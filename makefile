CC=clang-15

LLVM_BUILD_PATH=/lib/llvm-15

LLVM_BIN_PATH=$(LLVM_BUILD_PATH)/bin

LDFLAGS=`$(LLVM_BIN_PATH)/llvm-config --ldflags --libs --system-libs`

FLO_INSTALL_PATH=/usr/local/flo

define compile_and_link_fc
	$(1) src/main.flo --emit obj -o $(1).o -O 3 -I ./lib/
	$(CC) -no-pie $(1).o /tmp/llvm-bind.so $(LDFLAGS) -o $(2)
endef

all: flo

flo:
	$(CC) -c src/llvm/FloLLVMBind.cpp -o /tmp/llvm-bind.so
	$(CC) bootstrap/flo.ll /tmp/llvm-bind.so $(LDFLAGS) -o /tmp/stage0
	$(call compile_and_link_fc,/tmp/stage0,/tmp/stage1)
	$(call compile_and_link_fc,/tmp/stage1,$@)


check:
	./runtests.py

install:
	sudo mkdir -p $(FLO_INSTALL_PATH)
	sudo cp -f flo $(FLO_INSTALL_PATH)
	sudo cp -r lib $(FLO_INSTALL_PATH)
	sudo ln -f $(FLO_INSTALL_PATH)/flo /usr/bin/flo

clean:
	rm -rf flo 
