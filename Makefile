BUILD_DIR := build
LIB_TARGET := template
TEST_TARGET := tests

CMAKE_FLAGS := 
MAKE_FLAGS := -j $(shell nproc || sysctl -n hw.logicalcpu)

.PHONY: configure
configure:
	cmake -S . -B $(BUILD_DIR) $(CMAKE_FLAGS)

.PHONY: build_all
build_all: configure
	cmake --build $(BUILD_DIR) -- $(MAKE_FLAGS)
	
.PHONY: lib
lib: configure
	cmake --build $(BUILD_DIR) --target $(LIB_TARGET) -- $(MAKE_FLAGS)

.PHONY: test
test: configure
	cmake --build $(BUILD_DIR) --target $(TEST_TARGET) -- $(MAKE_FLAGS)
	./$(BUILD_DIR)/$(TEST_TARGET)

.PHONY: tidy
tidy: configure  # needed for compile commands database
	@if [ -z "$(CI)" ]; then \
		find . -iname '*.h' -o -iname '*.cpp' \
		-o -path ./$(BUILD_DIR) -prune -false \
		-o -path ./test -prune -false \
		| xargs clang-tidy -p ./$(BUILD_DIR) -warnings-as-errors='*'; \
	else \
		find . -iname '*.h' -o -iname '*.cpp' \
		-o -path ./$(BUILD_DIR) -prune -false \
		-o -path ./test -prune -false \
		| xargs clang-tidy -p ./$(BUILD_DIR); \
	fi

.PHONY: install
install: lib
	cmake --install $(BUILD_DIR)

.PHONY: uninstall
uninstall: configure
	cmake --build $(BUILD_DIR) --target uninstall
