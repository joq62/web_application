## set the paths for a default setup

all: beam
	erl -pa ../deps/cowboy/ebin\
            -pa ../deps/ranch/ebin\
            -pa ../deps/cowlib/ebin\
            -pa ../ebin\
	    -pa ./ebin\
	    -pa */ebin\
            -s  ezwebframe_demos start -sname stug

beam:
	rm -rf ebin/* stug/ebin/* basic lib_service include;
	cp stug/src/*.app stug/ebin;
	git clone https://github.com/joq62/basic.git;
	cp -r basic/include .;
	cp -r basic/lib_service .;
	cp lib_service/src/*.app lib_service/ebin;
	cp src/*.app ebin;
	erlc -o ebin src/*.erl;
	erlc -I include -o lib_service/ebin lib_service/src/*.erl
clean:
	rm -rf *~ *.beam *.tmp
