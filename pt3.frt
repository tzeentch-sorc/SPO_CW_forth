: IMMEDIATE
	lw_addr @ cfa 1 - dup c@ 1 or swap c! ;

: if
	' branch0 ,	curr_addr 0 , ; IMMEDIATE

: else
	' branch , curr_addr 0 , swap curr_addr swap ! ; IMMEDIATE

: then
	curr_addr swap ! ; IMMEDIATE	

: repeat 
	curr_addr ; IMMEDIATE

: until
	' branch0 ,	, ; IMMEDIATE

: for
	curr_addr ; IMMEDIATE

: end_cond
	' branch0 ,	curr_addr 0 , ' branch , curr_addr 0 , rot curr_addr ; IMMEDIATE

: end_loop
	' branch , swap curr_addr 0 , ! rot rot	curr_addr swap ! ; IMMEDIATE

: end_for
	' branch , 	swap curr_addr 0 , ! curr_addr swap ! ; IMMEDIATE

: for-value
	' >r , ' lit , 0 , ' >r ,
	' for execute
		' r> , ' dup , ' r> , ' dup , ' >r , ' swap , ' >r , ' < , ' 
		end_cond execute
		
		' r> , ' lit , 1 , ' + , ' >r ,	' 
		end_loop execute
;
IMMEDIATE

: end_for_value
	' end_for execute
	' r> ,
	' r> ,
	' drop ,
	' drop ,
;
IMMEDIATE
