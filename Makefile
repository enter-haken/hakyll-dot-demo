compile:
	ghc site.hs

clean:
	./site clean
	rm site
	rm *.hi
	rm *.o

build:
	./site build

show:
	cat _site/index.html

all: clean compile build show
	
