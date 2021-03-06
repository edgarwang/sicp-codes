;; 使用全局变量
(define balance 100)
(define (withdraw amount)
  (if (>= balance amount)
      (begin (set! balance (- balance amount))
	     balance)
      "Insufficient funds"))
;; 使用局部变量
(define new-withdraw
  (let ((balance 100))
    (lambda (amount)
      (if (>= balance amount)
	  (begin (set! balance (- balance amount))
		 balance)
	  "Insufficient funds"))))
;; 创建不同初始balance的withdraw函数
(define (make-withdraw balance)
  (lambda (amount)
    (if (>= balance amount)
	(begin (set! balance (- balance amount))
	       balance)
	"Insufficient funds")))

;; 比较完整的帐号操作
(define (make-account balance)
  (define (withdraw amount)
    (if (>= balance amount)
	(begin (set! balance (- balance amount))
	       balance)
	"Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch op)
    (cond ((eq? op 'withdraw)
	   withdraw)
	  ((eq? op 'deposit)
	   deposit)
	  (else (error "MAKE-ACCOUNT" "Unknown request" m))))
  dispatch)

;; Exercise 3.1
(define (make-accumulator sum)
  (lambda (val)
    (set! sum (+ val sum))
    sum))

;; Exercise 3.2
(define (make-monitored procedure)
  (let ((counter 0))
    (define (dispatch m)
      (cond ((eq? m 'how-many-calls?)
	     counter)
	    ((eq? m 'reset-count)
	     (set! counter 0))
	    (else
	     (set! counter (+ counter 1))
	     (procedure m))))
    dispatch))

;; Exercise 3.3
(define (make-account balance passwd)
  (define (withdraw amount)
    (if (>= balance amount)
	(begin (set! balance (- balance amount))
	       balance)
	"Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch user-passwd op)
    (if (eq? passwd user-passwd)
	(cond ((eq? op 'withdraw)
	       withdraw)
	      ((eq? op 'deposit)
	       deposit)
	      (else (error "MAKE-ACCOUNT" "Unknow request" op)))
	 (error "MAKE-ACCOUNT" "Incorrect password" user-passwd)))
  dispatch)

;; Exercise 3.4
(define (make-account balance passwd)
  (let ((incorrect-counter 0))
    (define (reset-counter)
      (set! incorrect-counter 0))
    (define (inc-counter)
      (set! incorrect-counter (+ incorrect-counter 1)))
    (define (is-counter-exceeds-the-limit)
      (if (>= incorrect-counter 7)
	  #t
	  #f))
    (define (withdraw amount)
      (if (>= balance amount)
	  (begin (set! balance (- balance amount))
		 balance)
	  "Insufficient funds"))
    (define (deposit amount)
      (set! balance (+ balance amount)))
    (define (call-the-cops amount)
      "Calling cops")
    (define (dispatch user-passwd m)
      (if (eq? user-passwd passwd)
	  (begin (reset-counter)
		 (cond ((eq? m 'withdraw)
			withdraw)
		       ((eq? m 'deposit)
			deposit)
		       (else (error "MAKE-ACCOUNT" "Unknown request" m))))
	  (begin (inc-counter)
		 (if (is-counter-exceeds-the-limit)
		     call-the-cops
		     (error "MAKE-ACCOUNT" "Password wrong" user-passwd)))))
    dispatch))

;; 使用 monte carlo 测试来计算PI值
;; (define rand
;;   (let ((x random-init))
;;     (lambda ()
;;       (set! x (rand-update x))
;;       x)))
;; 定义以下rand使monte-carlo可以正常运行
(define rand
  (lambda ()
    (random 1000)))
(define (estimate-pi trials)
  (sqrt (/ 6 (monte-carlo trials cesaro-test))))
(define (cesaro-test)
  (= (gcd (rand) (rand)) 1))
(define (monte-carlo trials experiment)
  (define (iter trials-remaining trials-passed)
    (cond ((= trials-remaining 0)
	   (/ trials-passed trials))
	  ((experiment)
	   (iter (- trials-remaining 1)
		 (+ trials-passed 1)))
	  (else
	   (iter (- trials-remaining 1)
		 trials-passed))))
  (iter trials 0))
;; 如果我们没有赋值操作
;; (define (estimate-pi trials)
;;   (sqrt (/ 6 (random-gcd-test trials random-init))))
;; (define (random-gcd-test trials initial-x)
;;   (define (iter trials-remaining trials-passed x)
;;     (let ((x1 (rand-update x)))
;;       (let ((x2 (rand-update x1)))
;; 	(cond ((= trials-remaining 0)
;; 	       (/ trials-passed trials))
;; 	      ((= (gcd x1 x2) 1)
;; 	       (iter (- trials-remaining 1)
;; 		     (+ trials-remaining 1)
;; 		     x2))
;; 	      (else
;; 	       (iter (- trials-remaining 1)
;; 		     trials-passed
;; 		     x2))))))
;;   (iter trials 0 initial-x))

;; Exercise 3.5
(define (random-in-range low high)
  (let ((range (- high low)))
    (+ low (random range))))
(define (integral-test pred x1 x2 y1 y2)
  (pred (random-in-range x1 x2) (random-in-range y1 y2)))
(define (estimate-integral pred x1 x2 y1 y2 trials)
  (* (- x2 x1) (- y2 y1) (monte-carlo trials
				      (lambda ()
					(integral-test pred x1 x2 y1 y2)))))

(define (square x)
  (* x x))
(define (sample-integral-pred x y)
  (>= (square 3) (+ (square (- x 5))
		    (square (- y 7)))))
(define (estimate-pi-2 trials)
  (/ (estimate-integral sample-integral-pred 2.0 8.0 4.0 10.0 trials)
     (square 3.0)))

;; Exercise 3.6
(define random-init 1)
(define (rand m)
  (let ((x random-init))
    (define (generate)
      (set! x (rand-update x))
      x)
    (define (reset seed)
      (set! x seed))
    (define (dispatch m)
      (cond ((eq? m 'generate)
	     (generate))
	    ((eq? m 'reset)
	     reset)
	    (else
	     (error "RAND" "Unknown message" m))))
    (dispatch m)))

;; The Costs of Introducing Assignment
(define (make-simplified-withdraw balance)
  (lambda (amount)
    (set! balance (- balance amount))
    balance))
(define (make-decrementer balance)
  (lambda (amount)
    (- balance amount)))

;; 两种factorial
(define (factorial n)
  (define (iter product counter)
    (if (> counter n)
	product
	(iter (* counter product) (+ counter 1))))
  (iter 1 1))
(define (factorial-imperative n)
  (let ((product 1)
	(counter 1))
    (define (iter)
      (if (> counter n)
	  product
	  (begin (set! product (* counter product))
		 (set! counter (+ counter 1))
		 (iter))))
    (iter)))

;; Exercise 3.8
(define (make-account balance passwd)
  (define (withdraw amount)
    (if (>= balance amount)
	(begin (set! balance (- balance amount))
	       balance)
	"Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (let ((password-list (list passwd)))
    (define (add-password new-passwd)
      (set! password-list (cons new-passwd password-list)))
    (define (dispatch user-passwd op)
      (if (memq user-passwd password-list)
	  (cond ((eq? op 'withdraw)
		 withdraw)
		((eq? op 'deposit)
		 deposit)
		((eq? op 'make-joint)
		 add-password)
		(else (error "MAKE-ACCOUNT" "Unknow request" op)))
	  (error "MAKE-ACCOUNT" "Incorrect password" user-passwd)))
    dispatch))
(define (make-joint account passwd new-passwd)
  ((account passwd 'make-joint) new-passwd)
  account)

;; Exercise 3.8
;; 一旦有一次参数为0，则以后总是返回0
;; 否则会返回参数
(define f
  (let ((always-return-zero #f))
    (lambda (n)
      (if always-return-zero
	  0
	  (if (= n 0)
	      (begin (set! always-return-zero #t)
		     0)
	      n)))))

;; Exercise 3.9
(define (factorial n)
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))
;; (factorial 6)执行时首先会创建环境E1，
;; E1里有参数n的绑定值6，factorial在全局环境中存在。
;; 由于(factorial 6)内部需要调用(factorial 5)，所以
;; 会创建环境E2，E2执行全局环境，同时包含参数n的绑定值5。
;; 依此类推，随后还会创建环境E3, E4, E5, E6。
(define (factorial n)
  (fact-iter 1 1 n))
(define (fact-iter product counter max-count)
  (if (> counter max-count)
      product
      (fact-iter (* product counter)
		 (+ counter 1)
		 max-count)))
;; 执行(factorial 6)时首先会创建环境E1，E1指向全局环境，同时保存有n的绑定值6。
;; 随后需要执行(fact-iter 1 1 n)，此时会创建环境E2，E2指向全局环境，同时保存
;; 了三个参数的绑定。然后由于fact-iter内部也需要调用fact-iter，所以又会接着创建
;; 环境E3, E4, E5, E6, E7, E8。

;; Exercise 3.10
;; from: http://wqzhang.wordpress.com/2009/07/13/sicp-exercise-3-10/
;; see https://dl.dropboxusercontent.com/u/63681644/images/sicp-ex-3-10.png

;; Exercise 3.11
;; from: http://wqzhang.wordpress.com/2009/07/14/sicp-exercise-3-11/
;; see https://dl.dropboxusercontent.com/u/63681644/images/sicp-ex-3-11.png

;; cons的实现
;; (define (my-cons x y)
;;   (let ((new (get-new-pair)))
;;     (set-car! new x)
;;     (set-cdr! new y)
;;     new))

;; Exercise 3.12
(define (append x y)
  (if (null? x)
      y
      (cons (car x) (append (cdr x) y))))
(define (append! x y)
  (set-cdr! (last-pair x) y)
  x)
(define (last-pair x)
  (if (null? (cdr x))
      x
      (last-pair (cdr x))))

;; (define x (list 'a 'b))
;; (define y (list 'c 'd))
;; (define z (append x y))
;; z
;; => (a b c d)
;; (cdr x)
;; => (b)
;; (define w (append! x y))
;; w
;; => (a b c d)
;; (cdr x)
;; => (b c d)

;; Exercise 3.13
(define (make-cycle x)
  (set-cdr! (last-pair x) x)
  x)
(define z (make-cycle (list 'a 'b 'c)))

;; (last-pair z)将会无限递归下去，因为last-pair的终止
;; 条件是参数的cdr为nil，但是由于z是一个环，它的cdr也依旧
;; 是一个环，不会变成nil，所以last-pair永远都不会停止。

;; Exercise 3.14
(define (mystery x)
  (define (loop x y)
    (if (null? x)
	y
	(let ((temp (cdr x)))
	  (set-cdr! x y)
	  (loop temp x))))
  (loop x '()))
;; mystery会将其参数(一个list)倒置并返回，同时会将其参数变为只
;; 包含第一个元素的列表。
;; (define v '(a b c))
;; (define w (mystery v))
;; v
;; => (a)
;; w
;; => (c b a)

(define (set-to-wow! x)
  (set-car! (car x) 'wow)
  x)
;; (define x (cons 'a 'b))
;; (define z1 (cons x x))
;; (define z2 (cons '(a b) '(a b)))
;; (set-to-wow! z1)
;; ((wow b) wow b)
;; (set-to-wow! z2)
;; ((wow b) a b)

;; Exercise 3.15
;; from: http://wqzhang.wordpress.com/2009/07/15/sicp-exercise-3-15/
;; see https://dl.dropboxusercontent.com/u/63681644/images/sicp-ex-3-15.png

;; Exercise 3.16
(define (count-pairs x)
  (if (not (pair? x))
      0
      (+ (count-pairs (car x))
	 (count-pairs (cdr x))
	 1)))
(define z1 '(a b c))
(count-pairs z1)
;; => 3
(define x '(a))
(define z2 (list x x))
(count-pairs z2)
;; => 4
(define x '(a))
(define y (cons x x))
(define z3 (cons y y))
(count-pairs z3)
;; => 7
(define z4 '(a b c))
(set-cdr! (cddr z4) z4)
;; (count-pairs z4) ;;无限递归

;; Exercise 3.17
(define (count-pairs lst)
  (let ((visited-pairs '()))
    (define (do-count-pairs lst)
      (if (not (pair? lst))
	  0
	  (if (memq lst visited-pairs)
	      (+ (do-count-pairs (car lst))
		 (do-count-pairs (cdr lst)))
	      (begin (set! visited-pairs (cons lst visited-pairs))
		     (+ (do-count-pairs (car lst))
			(do-count-pairs (cdr lst))
			1)))))
    (do-count-pairs lst)))

;; Exercise 3.18
(define (cycle? lst)
  (let ((unique-pairs '()))
    (define (do-detect-cycle lst)
      (let ((lst-cdr (cdr lst)))
	(if (null? lst-cdr)
	    #f
	    (begin (set! unique-pairs (cons lst unique-pairs))
		   (if (memq lst-cdr unique-pairs)
		       #t
		       (do-detect-cycle lst-cdr))))))
    (do-detect-cycle lst)))

;; Exercise 3.19
;; using http://en.wikipedia.org/wiki/Cycle_detection#Tortoise_and_hare
(define (cycle? lst)
  (define (get-slow lst)
    (if (null? lst)
	'()
	(cdr lst)))
  (define (get-fast lst)
    (cond ((null? lst) '())
	  ((null? (cdr lst)) '())
	  (else (cddr lst))))
  (define (detect-cycle slow fast)
    (cond ((or (null? slow) (null? fast))
	   #f)
	  ((eq? slow fast)
	   #t)
	  (else
	   (detect-cycle (get-slow slow) (get-fast fast)))))
  (detect-cycle (get-slow lst) (get-fast lst)))


(define (my-cons x y)
  (define (dispatch m)
    (cond ((eq? m 'car) x)
	  ((eq? m 'cdr) y)
	  (else (error "MY-CONS" "Undefined operation" m))))
  dispatch)
(define (my-car z) (z 'car))
(define (my-cdr z) (z 'cdr))

(define (my-cons x y)
  (define (set-x! v) (set! x v))
  (define (set-y! v) (set! y v))
  (define (dispatch m)
    (cond ((eq? m 'car) x)
	  ((eq? m 'cdr) y)
	  ((eq? m 'set-car!) set-x!)
	  ((eq? m 'set-cdr!) set-y!)
	  (else
	   (error "MY-CONS" "Undefined operation" m))))
  dispatch)
(define (my-car z) (z 'car))
(define (my-cdr z) (z 'cdr))
(define (my-set-car! z new-value)
  ((z 'set-car!) new-value)
  z)
(define (my-set-cdr! z new-value)
  ((z 'set-cdr!) new-value)
  z)

;; Exercise 3.20
;; from http://wizardbook.wordpress.com/2010/12/16/exercise-3-20/
;; see https://dl.dropboxusercontent.com/u/63681644/images/sicp-ex-3-20.png

(define (front-ptr queue)
  (car queue))
(define (rear-ptr queue)
  (cdr queue))
(define (set-front-ptr! queue item)
  (set-car! queue item))
(define (set-rear-ptr! queue item)
  (set-cdr! queue item))
(define (empty-queue? queue)
  (null? (front-ptr queue)))
(define (make-queue)
  (cons '() '()))
(define (front-queue queue)
  (if (empty-queue? queue)
      (error "FRONT-QUEUE" "called with an empty queue" queue)
      (car (front-ptr queue))))
(define (insert-queue! queue item)
  (let ((new-pair (cons item '())))
    (cond ((empty-queue? queue)
	   (set-front-ptr! queue new-pair)
	   (set-rear-ptr! queue new-pair)
	   queue)
	  (else
	   (set-cdr! (rear-ptr queue) new-pair)
	   (set-rear-ptr! queue new-pair)
	   queue))))
(define (delete-queue! queue)
  (cond ((empty-queue? queue)
	 (error "DELETE-QUEUE!" "called with an empty queue"))
	(else
	 (set-front-ptr! queue (cdr (front-ptr queue)))	 
	 queue)))

;; Exercise 3.21
(define (print-queue queue)
  (display (front-ptr queue)))

;; Exercise 3.22
(define (make-queue-2)
  (let ((front-ptr '())
	(rear-ptr '()))
    (define (print-queue)
      (display front-ptr))
    (define (empty-queue?)
      (null? front-ptr))
    (define (front-queue)
      (if (empty-queue?)
	  (error "FRONT-QUEUE" "called with an empty queue")
	  (car front-ptr)))
    (define (insert-queue! item)
      (let ((new-pair (cons item '())))
	(cond ((empty-queue?)
	       (set! front-ptr new-pair)
	       (set! rear-ptr new-pair)
	       front-ptr)
	      (else
	       (set-cdr! rear-ptr new-pair)
	       (set! rear-ptr new-pair)
	       front-ptr))))
    (define (delete-queue!)
      (cond ((empty-queue?)
	     (error "DELETE-QUEUE!" "called with empty queue"))
	    (else
	     (set! front-ptr (cdr front-ptr))
	     front-ptr)))
    (define (dispatch m)
      (cond ((eq? m 'front-queue)
	     front-queue)
	    ((eq? m 'insert-queue!)
	     insert-queue!)
	    ((eq? m 'delete-queue!)
	     delete-queue!)
	    ((eq? m 'empty-queue?)
	     empty-queue?)
	    (else
	     (error "QUEUE" "unknown message" m))))
    dispatch))

;; Exercise 3.23
(define (make-deque)
  (cons '() '()))
(define (deque-front-ptr deque)
  (car deque))
(define (deque-rear-ptr deque)
  (cdr deque))
(define (deque-set-front-ptr! deque item)
  (set-car! deque item))
(define (deque-set-rear-ptr! deque item)
  (set-cdr! deque item))

(define (empty-deque? deque)
  (and (null? (deque-front-ptr deque))
       (null? (deque-rear-ptr deque))))
(define (front-deque deque)
  (if (empty-deque? deque)
      (error "FRONT-DEQUE" "called with empty deque")
      (car (deque-front-ptr deque))))
(define (rear-deque deque)
  (if (empty-deque? deque)
      (error "REAR-DEQUE" "called with empty deque")
      (car (deque-rear-ptr deque))))
(define (front-insert-deque! deque item)
  (let ((new-pair (cons item (cons '() '()))))
    (cond ((empty-deque? deque)
	   (deque-set-front-ptr! deque new-pair)
	   (deque-set-rear-ptr! deque new-pair))
	  (else
	   (set-cdr! (cdr new-pair) (deque-front-ptr deque))
	   (set-car! (cdr (deque-front-ptr deque)) new-pair)
	   (deque-set-front-ptr! deque new-pair)))))
(define (rear-insert-deque! deque item)
  (let ((new-pair (cons item (cons '() '()))))
    (cond ((empty-deque? deque)
	   (deque-set-front-ptr! deque new-pair)
	   (deque-set-rear-ptr! deque new-pair))
	  (else
	   (set-car! (cdr new-pair) (deque-rear-ptr deque))
	   (set-cdr! (cdr (deque-rear-ptr deque)) new-pair)
	   (deque-set-rear-ptr! deque new-pair)))))
(define (front-delete-deque! deque)
  (cond ((empty-deque? deque)
	 (error "FRONT-DELETE-DEQUE!" "called with empty deque"))
	((eq? (deque-front-ptr deque) (deque-rear-ptr deque))
	 (deque-set-front-ptr! deque '())
	 (deque-set-rear-ptr! deque '()))
	(else
	 (deque-set-front-ptr! deque (cddr (deque-front-ptr deque)))
	 (set-car! (cdr (deque-front-ptr deque)) '()))))
(define (rear-delete-deque! deque)
  (cond ((empty-deque? deque)
	 (error "REAR-DELETE-DEQUE!" "called with empty deque"))
	((eq? (deque-front-ptr deque) (deque-rear-ptr deque))
	 (deque-set-front-ptr! deque '())
	 (deque-set-rear-ptr! deque '()))
	(else
	 (deque-set-rear-ptr! deque (cadr (deque-rear-ptr deque)))
	 (set-cdr! (cdr (deque-rear-ptr deque)) '()))))
(define (print-deque deque)
  (define (make-printable-list q)
    (if (null? q)
        '()
        (cons (car q) 
              (make-printable-list (cddr q)))))
  (newline)
  (display (make-printable-list (front-ptr deque))))

;; one dimensional table
(define (lookup key table)
  (let ((record (assoc key (cdr table))))
    (if record
	(cdr record)
	#f)))
(define (assoc key records)
  (cond ((null? records)
	 #f)
	((equal? key (caar records))
	 (car records))
	(else (assoc key (cdr records)))))
(define (insert-table! key value table)
  (let ((record (assoc key  (cdr table))))
    (if record
	(set-cdr! record value)
	(set-cdr! table
		  (cons (cons key value)
			(cdr table)))))
  'OK)
(define (make-table)
  (list '*table*))

;; two dimensional table
(define (lookup-two-dim key-1 key-2 table)
  (let ((subtable (assoc key-1 (cdr table))))
    (if subtable
	(let ((record (assoc key-2 (cdr subtable))))
	  (if record
	      (cdr record)
	      #f))
	#f)))
(define (insert-two-dim-table! key-1 key-2 value table)
  (let ((subtable (assoc key-1 (cdr table))))
    (if subtable
	(let ((record (assoc key-2 (cdr subtable))))
	  (if record
	      (set-cdr! record value)
	      (set-cdr! subtable
			(cons (cons key-2 value)
			      (cdr subtable)))))
	(set-cdr! table
		  (cons (list key-1
			      (cons key-2 value))
			(cdr table)))))
  'OK)

;; local table
(define (make-table-0)
  (let ((local-table (list '*table*)))
    (define (lookup key-1 key-2)
      (let ((subtable (assoc key-1 (cdr local-table))))
	(if subtable
	    (let ((record (assoc key-2 (cdr subtable))))
	      (if record
		  (cdr record)
		  #f))
	    #f)))
    (define (insert! key-1 key-2 value)
      (let ((subtable (assoc key-1 (cdr local-table))))
	(if subtable
	    (let ((record (assoc key-2 (cdr subtable))))
	      (if record
		  (set-cdr! record value)
		  (set-cdr! subtable
			    (cons (cons key-2 value)
				  (cdr subtable)))))
	    (set-cdr! local-table
		      (cons (list key-1 (cons key-2 value))
			    (cdr local-table)))))
      'OK)
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
	    ((eq? m 'insert-proc!) insert!)
	    (else (error "TABLE" "Unknown operation" m))))
    dispatch))
(define operation-table (make-table-0))
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc!))

;; Exercise 3.24
(define (make-table-2 same-key?)
  (let ((local-table (list '*table*)))
    (define (assoc key records)
      (cond ((null? records) #f)
	    ((same-key? key (caar records)) (car records))
	    (else
	     (assoc key (cdr records)))))
    (define (lookup key-1 key-2)
      (let ((subtable (assoc key-1 (cdr local-table))))
	(if subtable
	    (let ((record (assoc key-2 (cdr subtable))))
	      (if record
		  (cdr record)
		  #f))
	    #f)))
    (define (insert! key-1 key-2 value)
      (let ((subtable (assoc key-1 (cdr local-table))))
	(if subtable
	    (let ((record (assoc key-2 (cdr subtable))))
	      (if record
		  (set-cdr! record value)
		  (set-cdr! subtable
			    (cons (cons key-2 value)
				  (cdr subtable)))))
	    (set-cdr! local-table
		      (cons (list key-1 (cons key-1 value))
			    (cdr local-table)))))
      'OK)
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
	    ((eq? m 'insert-proc!) insert!)
	    (else (error "TABLE" "Unknown operation" m))))
    dispatch))

;; Exercise 3.25
(define (make-table-3)
  (let ((local-table (list '*table*)))
    (define (lookup key-list)
      (define (lookup-table key-list table)
	(let ((subtable (assoc (car key-list) (cdr table))))
	  (if subtable
	      (if (null? (cdr key-list))
		  (cdr subtable)
		  (lookup-table (cdr key-list) (cdr subtable)))
	      #f)))
      (lookup-table key-list local-table))
    (define (insert! key-list value)
      (define (make-entry keys)
	(if (null? (cdr keys))
	    (cons (car keys) value)
	    (list (car keys) (make-entry (cdr keys)))))
      (define (insert-table! key-list table)
	(let ((subtable (assoc (car key-list) (cdr table))))
	  (if subtable
	      (if (null? (cdr key-list))
		  (set-cdr! subtable value)
		  (insert-table! (cdr key-list) subtable))
	      (set-cdr! table
			(cons (make-entry key-list)
			      (cdr table))))))
      (insert-table! key-list local-table)
      'OK)
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
	    ((eq? m 'insert-proc!) insert!)
	    (else (error "TABLE" "Unknown operation" m))))
    dispatch))

;; Exercise 3.26
(define (entry tree) (car tree))
(define (left-branch tree) (cadr tree))
(define (right-branch tree) (caddr tree))
(define (make-tree entry left right)
  (list entry left right))
(define (adjoin-set x set)
  (cond ((null? set) (make-tree x '() '()))
	((entry-= x (entry set)) set)
	((entry-< x (entry set))
	 (make-tree (entry set)
		    (adjoin-set x (left-branch set))
		    (right-branch set)))
	(else
	 (make-tree (entry set)
		    (left-branch set)
		    (adjoin-set x (right-branch set))))))
(define (lookup-tree given-key set-of-records)
  (if (null? set-of-records)
      #f
      (let ((record (entry set-of-records)))
	(cond ((= given-key (key record))
	       record)
	      ((< given-key (key record))
	       (lookup-tree given-key (left-branch set-of-records)))
	      ((> given-key (key record))
	       (lookup-tree (right-branch set-of-records)))))))
(define (key record)
  (car record))
(define (entry-= x y)
  (key-= (key x) (key y)))
(define (entry-< x y)
  (key-< (key x) (key y)))
(define (entry-> x y)
  (key-> (key x) (key y)))
(define key-= =)
(define key-< <)
(define key-> >)

(define (make-table-4)
  (let ((local-table (list '*table*)))
    (define (lookup key-list) 
      (define (lookup1 keys table)
        (let ((subtable (lookup-tree (car keys) (cdr table))))
          (if subtable
              (if (null? (cdr keys))
                  (cdr subtable)
                  (lookup1 (cdr keys) subtable))
              false)))
      (lookup1 key-list local-table))
    (define (insert! key-list value)
      (define (make-entry keys)
        (if (null? (cdr keys)) 
            (cons (car keys) value)
            (cons (car keys)
                  (make-tree (make-entry (cdr keys))
                             '() '()))))
      (define (insert1 keys table) 
        (let ((subtable (lookup-tree (car keys) (cdr table))))
          (if subtable
              (if (null? (cdr keys))
                  (set-cdr! subtable value)
                  (insert1 (cdr keys) subtable))
              (set-cdr! table (adjoin-set (make-entry keys)
                                          (cdr table))))))
      (insert1 key-list local-table)
      'ok)
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
            ((eq? m 'insert-proc!) insert!)
            (else (error "Unknown operation -- TABLE" m))))
    dispatch))

;; Exercise 3.27
(define (memoize f)
  (let ((table (make-table)))
    (lambda (x)
      (let ((previously-computed-result
	     (lookup x table)))
	(or previously-computed-result
	    (let ((result (f x)))
	      (insert-table! x result table)
	      result))))))
(define memo-fib
  (memoize
   (lambda (n)
     (cond ((= n 0) 0)
	   ((= n 1) 1)
	   (else (+ (memo-fib (- n 1))
		    (memo-fib (- n 2))))))))
;; memo-fib在计算第n个fibonacci数的时候不在
;; 需要重复计算已计算出来的值，那么它所要计算的值
;; 则是(fib 0) -> (fib (- n 1))，因而其复杂度为O(n)。
;; 直接使用(memoize fib)的话，那么它还是要重复计算
;; (fib (- n 1))和(fib (- n 2))。

;; half-adder
;; half-adder
(define (half-adder a b s c)
  (let ((d (make-wire))
	(e (make-wire)))
    (or-gate a b d)
    (and-gate a b c)
    (inverter c e)
    (and-gate d e s)
    'OK))
(define (full-adder a b c-in sum c-out)
  (let ((s (make-wire))
	(c1 (make-wire))
	(c2 (make-wire)))
    (half-adder b c-in s c1)
    (half-adder a s sum c2)
    (or-gate c1 c2 c-out)
    'OK))

(define (inverter input output)
  (define (invert-input)
    (let ((new-value (logical-not (get-signal input))))
      (after-delay inverter-delay
		   (lambda () (set-signal! output new-value)))))
  (add-action! input invert-input)
  'OK)
(define (logical-not s)
  (cond ((= s 0) 1)
	((= s 1) 0)
	(else (error "LOGICAL-NOT" "Invalid signal" s))))

(define (and-gate a1 a2 output)
  (define (and-action-procedure)
    (let ((new-value
	   (logical-and (get-signal a1) (get-signal a2))))
      (after-delay and-gate-delay
		   (lambda () (set-signal! output new-value)))))
  (add-action! a1 and-action-procedure)
  (add-action! a2 and-action-procedure)
  'OK)
(define (logical-and a b)
  (cond ((and (= a 1) (= b 1)) 1)
	((or (= a 0) (= b 0)) 0)
	(else (error "LOGICAL-AND" "Invalid signals" a b))))

;; Exercise 3.28
(define (or-gate a1 a2 output)
  (define (or-gate-procedure)
    (let ((new-value
	   (logical-or (get-signal a1) (get-signal a2))))
      (after-delay or-gate-delay
		   (lambda () (set-signal! output new-value)))))
  (add-action! a1 or-gate-procedure)
  (add-action! a2 or-gate-procedure)
  'OK)
(define (logical-or a b)
  (cond ((and (= a 0) (= b 0)) 0)
	((or (= a 1) (= b 1)) 1)
	(else (error "LOGICAL-OR" "Invalid signals" a b))))

;; Exercise 3.29
(define (compound-or-gate a1 a2 output)
  (define (or-gate-procedure)
    (let ((not-a1 (make-wire))
	  (not-a2 (make-wire))
	  (b (make-wire)))
      (inverter a1 not-a1)
      (inverter a2 not-a2)
      (and-gate not-a1 not-a2 b)
      (inverter b output)))
  (add-action! a1 or-gate-procedure)
  (add-action! a2 or-gate-procedure)
  'OK)
;; 这个or gate实现的延时是一个and gate的延时加上两个inverter的延时

;; Exercise 3.30
(define (ripple-carry-adder a-list b-list s-list c)
  (define (make-carry-list sum-list)
    (if (null? sum-list)
	'()
	(cons (make-wire)
	      (make-carry-list (cdr sum-list)))))
  (define (do-ripple-carray-adder a-list b-list c-in-list s-list c)
    (cond ((null? (cdr c-in-list))
	   (full-adder (car a-list)
		       (car b-list)
		       (car c-in-list)
		       (car s-list)
		       c))
	  (else
	   (full-adder (car a-list)
		       (car b-list)
		       (car c-in-list)
		       (car s-list)
		       (cadr c-in-list))
	   (do-ripple-carray-adder (cdr a-list)
				   (cdr b-list)
				   (cdr c-in-list)
				   (cdr s-list)
				   c))))
  (let ((c-in-list (make-carry-list s-list)))
    (set-signal! (car c-in-list) 0) ;; first c-in is 0
    (do-ripple-carray-adder a-list b-list c-in-list s-list c)))
;; a short version
(define (ripple-carry-adder a-list b-list s-list c)
  (let ((c-in (make-wire)))
    (if (null? (cdr s-list))
	(set-signal! c-in 0)
	(ripple-carry-adder (cdr a-list) (cdr b-list) (cdr s-list) c-in))
    (full-adder (car a-list) (car b-list) c-in (car s-list) c)))
;; delay = n * full-adder-delay
;; = n * (half-adder-delay*2 + or-gate-delay)
;; = n * (2*(max(and-gate-delay+inverter-delay, or-gate-delay)
;;           + and-gate-delay)
;;        + or-gate-delay)

;; wire representation
(define (make-wire)
  (let ((signal-value 0)
	(action-procedures '()))
    (define (set-my-signal! new-value)
      (if (not (= signal-value new-value))
	  (begin (set! signal-value new-value)
		 (call-each action-procedures))
	  'done))
    (define (accept-action-procedure! proc)
      (set! action-procedures
	    (cons proc action-procedures))
      (proc))
    (define (dispatch m)
      (cond ((eq? m 'get-signal) signal-value)
	    ((eq? m 'set-signal!) set-my-signal!)
	    ((eq? m 'add-action!) accept-action-procedure!)
	    (else (error "WIRE" "Unknown operation" m))))
    dispatch))
(define (call-each procedures)
  (if (null? procedures)
      'done
      (begin ((car procedures))
	     (call-each (cdr procedures)))))

(define (get-signal wire)
  (wire 'get-signal))
(define (set-signal! wire new-value)
  ((wire 'set-signal!) new-value))
(define (add-action! wire action-procedure)
  ((wire 'add-action!) action-procedure))

;; a sample simulation
(define (after-delay delay action)
  (add-to-agenda! (+ delay (current-time-agenda the-agenda))
		  action
		  the-agenda))
(define (propagate)
  (if (empty-agenda? the-agenda)
      'done
      (let ((first-item (first-agenda-item the-agenda)))
	(first-item)
	(remove-first-agenda-item! the-agenda)
	(propagate))))
(define (probe name wire)
  (add-action! wire
	       (lambda ()
		 (newline)
		 (display name)
		 (display " ")
		 (display (current-time-agenda the-agenda))
		 (display " New-value = ")
		 (display (get-signal wire)))))
(define inverter-delay 2)
(define and-gate-delay 3)
(define or-gate-delay 5)

;; Exercise 3.31
;; 如果不立刻运行action的话，agenda表就是空的了。

;; implementing the agenda
(define (make-time-segment time queue)
  (cons time queue))
(define (segment-time s) (car s))
(define (segment-queue s) (cdr s))

(define (make-agenda)
  (list 0))
(define (current-time-agenda agenda)
  (car agenda))
(define (set-current-time! agenda time)
  (set-car! agenda time))
(define (segments agenda)
  (cdr agenda))
(define (set-segments! agenda segments)
  (set-cdr! agenda segments))
(define (first-segment agenda)
  (car (segments agenda)))
(define (rest-segments agenda)
  (cdr (segments agenda)))
(define (empty-agenda? agenda)
  (null? (segments agenda)))

(define (add-to-agenda! time action agenda)
  (define (belongs-before? segments)
    (or (null? segments)
	(< time (segment-time (car segments)))))
  (define (make-new-time-segment time action)
    (let ((q (make-queue)))
      (insert-queue! q action)
      (make-time-segment time q)))
  (define (add-to-segments! segments)
    (if (= (segment-time (car segments)) time)
	(insert-queue! (segment-queue (car segments))
		       action)
	(let ((rest (cdr segments)))
	  (if (belongs-before? rest)
	      (set-cdr!
	       segments
	       (cons (make-new-time-segment time action)
		     (cdr segments)))
	      (add-to-segments! rest)))))
  (let ((segments (segments agenda)))
    (if (belongs-before? segments)
	(set-segments!
	 agenda
	 (cons (make-new-time-segment time action)
	       segments))
	(add-to-segments! segments))))

(define (remove-first-agenda-item! agenda)
  (let ((q (segment-queue (first-segment agenda))))
    (delete-queue! q)
    (if (empty-queue? q)
	(set-segments! agenda (rest-segments agenda)))))
(define (first-agenda-item agenda)
  (if (empty-agenda? agenda)
      (error "FIRST-AGENDA-ITEM" "Agenda is empty")
      (let ((first-seg (first-segment agenda)))
	(set-current-time! agenda
			   (segment-time first-seg))
	(front-queue (segment-queue first-seg)))))
(define the-agenda (make-agenda))

;; Exercise 3.32
;; 顺序是非常重要的，以and-gate为例来说明。
;; and-gate的procedure是(lambda () (set-signal! ouput new-value))，
;; 这里的new-value是依赖于procedure执行时的输入线的状态的。比如下面的
;; 操作: (and-gate input-1 input-2 output)，(set-signal! input-1 1)
;; (set-signal! input-2 1)。上面的三个操作都会将procedure加入到agenda
;; 中，如果它们是first in, first out执行的话，最终的结果会由
;; (set-signal! input-2 1)执行时加入aganda的procedure觉得，即值为1。
;; 如果按照first in, last out执行的话，最终结果会由(and-gate input-1 input-2 output)
;; 执行时加入agenda的procedure觉得，即值为0。

;; celsius fahrenheit converter
(define (celsius-fahrenheit-converter c f)
  (let ((u (make-connector))
	(v (make-connector))
	(w (make-connector))
	(x (make-connector))
	(y (make-connector)))
    (multiplier c w u)
    (multiplier v x u)
    (adder v y f)
    (constant 9 w)
    (constant 5 x)
    (constant 32 y)
    'ok))

;; implementing the constraint system
(define (adder a1 a2 sum)
  (define (process-new-value)
    (cond ((and (has-value? a1) (has-value? a2))
	   (set-value! sum
		       (+ (get-value a1) (get-value a2))
		       me))
	  ((and (has-value? a1) (has-value? sum))
	   (set-value! a2
		       (- (get-value sum) (get-value a1))
		       me))
	  ((and (has-value? a2) (has-value? sum))
	   (set-value! a1
		       (- (get-value sum) (get-value a2))
		       me))))
  (define (process-forget-value)
    (forget-value! sum me)
    (forget-value! a1 me)
    (forget-value! a2 me)
    (process-new-value))
  (define (me request)
    (cond ((eq? request 'I-have-a-value)
	   (process-new-value))
	  ((eq? request 'I-lost-my-value)
	   (process-forget-value))
	  (else
	   (error "ADDER" "Unknown request" request))))
  (connect a1 me)
  (connect a2 me)
  (connect sum me)
  me)

(define (inform-about-value constraint)
  (constraint 'I-have-a-value))
(define (inform-about-no-value constraint)
  (constraint 'I-lost-my-value))

(define (multiplier m1 m2 product)
  (define (process-new-value)
    (cond ((or (and (has-value? m1) (= (get-value m1) 0))
	       (and (has-value? m2) (= (get-value m2) 0)))
	   (set-value! product 0 me))
	  ((and (has-value? m1) (has-value? m2))
	   (set-value! product
		       (* (get-value m1) (get-value m2))
		       me))
	  ((and (has-value? product) (has-value? m1))
	   (set-value! m2
		       (/ (get-value product) (get-value m1))
		       me))
	  ((and (has-value? product) (has-value? m2))
	   (set-value! m1
		       (/ (get-value product) (get-value m2))
		       me))))
  (define (process-forget-value)
    (forget-value! product me)
    (forget-value! m1 me)
    (forget-value! m2 me)
    (process-new-value))
  (define (me request)
    (cond ((eq? request 'I-have-a-value)
	   (process-new-value))
	  ((eq? request 'I-lost-my-value)
	   (process-forget-value))
	  (else (error "MULTIPLIER" "Unknown request" request))))
  (connect m1 me)
  (connect m2 me)
  (connect product me)
  me)

(define (constant value connector)
  (define (me request)
    (error "CONSTANT" "Unknown request" request))
  (connect connector me)
  (set-value! connector value me)
  me)

(define (probe-connector name connector)
  (define (print-probe value)
    (newline) (display "Probe: ") (display name)
    (display " = ") (display value))
  (define (process-new-value)
    (print-probe (get-value connector)))
  (define (process-forget-value)
    (print-probe "?"))
  (define (me request)
    (cond ((eq? request 'I-have-a-value)
	   (process-new-value))
	  ((eq? request 'I-lost-my-value)
	   (process-forget-value))
	  (else (error "PROBE" "Unknown request" request))))
  (connect connector me)
  me)

;; represent connector
(define (has-value? connector)
  (connector 'has-value?))
(define (get-value connector)
  (connector 'value))
(define (set-value! connector new-value informat)
  ((connector 'set-value!) new-value informat))
(define (forget-value! connector retractor)
  ((connector 'forget) retractor))
(define (connect connector new-constraint)
  ((connector 'connect) new-constraint))

(define (make-connector)
  (let ((value #f)
	(informat #f)
	(constraints '()))
    (define (set-my-value newval setter)
      (cond ((not (has-value? me))
	     (set! value newval)
	     (set! informat setter)
	     (for-each-except setter
			      inform-about-value
			      constraints))
	    ((not (= value newval))
	     (error "CONNECTOR" "Contradiction" (list value newval)))
	    (else 'ignored)))
    (define (forget-my-value retractor)
      (if (eq? retractor informat)
	  (begin (set! informat #f)
		 (for-each-except retractor
				  inform-about-no-value
				  constraints))
	  'ignored))
    (define (connect new-constraint)
      (if (not (memq new-constraint constraints))
	  (set! constraints
		(cons new-constraint constraints)))
      (if (has-value? me)
	  (inform-about-value new-constraint))
      'done)
    (define (me request)
      (cond ((eq? request 'has-value?)
	     (if informat #t #f))
	    ((eq? request 'value) value)
	    ((eq? request 'set-value!) set-my-value)
	    ((eq? request 'forget) forget-my-value)
	    ((eq? request 'connect) connect)
	    (else "CONNECTOR" "Unknown operation" request)))
    me))
(define (for-each-except exception procedure lst)
  (define (loop items)
    (cond ((null? items) 'done)
	  ((eq? (car items) exception) (loop (cdr items)))
	  ((eq? (procedure (car items))
		(loop (cdr items))))))
  (loop lst))

;; Exercise 3.33
(define (averager a b c)
  (let ((u (make-connector))
	(v (make-connector)))
    (adder a b u)
    (multiplier c v u)
    (constant 2 v)
    'ok))

;; Exercise 3.34
;; (define (squarer a b)
;;   (multiplier a a b))
;; 上面定义的squarer的问题在于：
;;   虽然我们可以通过设置a的值来获取b的值，
;;   但是我们无法通过设置b的值来获得a的值。
;;   因为设置a的值相当于同时设置了两个connector的值，
;;   而设置b的值只会影响b这一个connector的值，a代表的
;;   2个connector都是没有值的，因而无法计算出a的值。

;; Exercise 3.35
(define (square x)
  (* x x))
(define (squarer a b)
  (define (process-new-value)
    (if (has-value? b)
	(if (< (get-value b) 0)
	    (error "SQUARER" "square less than 0" (get-value b))
	    (set-value! a (sqrt (get-value b)) me))
	(if (has-value? a)
	    (set-value! b (square (get-value a)) me))))
  (define (process-forget-value)
    (forget-value! a me)
    (forget-value! b me)
    (process-new-value))
  (define (me request)
    (cond ((eq? request 'I-have-a-value) (process-new-value))
	  ((eq? request 'I-lost-my-value) (process-forget-value))
	  (else
	   (error "SQUARER" "Unknown request" request))))
  (connect a me)
  (connect b me)
  me)

;; Exercise 3.36
;; TODO

;; Exercise 3.37
(define (celsius-fahrenheit-converter-2 x)
  (c+ (c* (c/ (cv 9) (cv 5))
	  x)
      (cv 32)))
(define (c+ x y)
  (let ((z (make-connector)))
    (adder x y z)
    z))
(define (c* x y)
  (let ((z (make-connector)))
    (multiplier x y z)
    z))
(define (c/ x y)
  (let ((z (make-connector)))
    (multiplier y z x)
    z))
(define (cv x)
  (let ((z (make-connector)))
    (constant x z)
    z))

;; Exercise 3.38
;; 1) 可能的值分别是35, 40, 45, 50
;; 2) TODO, see: http://wqzhang.wordpress.com/2009/07/30/sicp-exercise-3-38/

;; Exercise 3.39
;; 还有三种会剩下
;; 1) 101, P1将x设置为100，P2再将x设为101
;; 2) 121, P2将x设置为11, P1再将x设为121
;; 3) 100, P1计算出(* x x)的值为100，P2将x设为11，P1再将P1设为100

;; Exercise 3.40
;; 无serializer时同一个函数内对x的多次访问可能会获得不同的值，
;; 从而影响到最终的结果。
;; 加入serializer之后只有两种情况，100^3或1000^2。

;; Exercise 3.41
;; Ben的担心是多余的，因为会修改balance的deposit和withdraw都被保护了。
;; 对balance获取增加保护也是可取的，因为它可以使每次取出的balance都是
;; 准确的，不会是withdraw或deposit执行中的中间结果。

;; Exercise 3.42
;; 这个改变是完全安全的。它们的concurrency行为是一致的。


(define (make-account-and-serializer balance)
  (define (withdraw amount)
    (if (>= balance amount)
	(begin (set! balance (- balance amount))
	       balance)
	"Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (let ((balance-serializer (make-serializer)))
    (define (dispatch m)
      (cond ((eq? m 'withdraw) withdraw)
	    ((eq? m 'deposit) deposit)
	    ((eq? m 'balance) balance)
	    ((eq? m 'serializer) balance-serializer)
	    (else (error "ACCOUNT" "Unknown request" m))))
    dispatch))

;; Exercise 3.43
;; see http://wqzhang.wordpress.com/2009/08/03/sicp-exercise-3-43/

;; Exercise 3.44
;; Louis是错的，transfer只要保证总额不变就可以了。

;; Exercise 3.45
;; Louis的方法有很大问题。在执行serialized-exchange时，
;; 由于serializer已经被调用了，等到执行(account1 'withdraw)和
;; (account2 'deposit)时，serializer根本不会被release，这两
;; 个函数也无法执行。

(define (make-serializer)
  (let ((mutex (make-mutex)))
    (lambda (p)
      (define (serialized-p . args)
	(mutex 'acquire)
	(let ((val (apply p args)))
	  (mutex 'release)
	  val))
      serialized-p)))
(define (make-mutex)
  (define (clear! cell)
    (set-car! cell false))
  (define (test-and-set! cell) ;; this procedure should be atomatic
    (if (car cell)
	true
	(begin (set-car! cell true)
	       false)))
  (let ((cell (list false)))
    (define (the-mutex m)
      (cond ((eq? m 'acquire)
	     (if (test-and-set! cell)
		 (the-mutex 'acquire)))
	    ((eq? m 'release)
	     (clear! cell))))
    the-mutex))

;; Exercise 3.46
;; test-and-set!可能会在(car cell)之后被打断，
;; 从而导致两个对test-and-set!的调用都成功的
;; 上了锁，也失去了上锁的效果。

;; Exercise 3.47
(define (make-semaphore1 n)
  (let ((mutex (make-mutex))
	(count 0))
    (define (the-semaphore m)
      (cond ((eq? m 'acquire)
	     (mutex 'acquire)
	     (if (= count n)
		 (begin (mutex 'release)
			(the-semaphore 'acquire))
		 (begin (set! count (+ count 1))
			(mutex 'release))))
	    ((eq? m 'release)
	     (mutex 'acquire)
	     (if (> count 0)
		 (set! count (- count 1)))
	     (mutex 'release))))
    the-semaphore))

(define (make-semaphore2 n)
  (let ((cell (list #f))
	(count 0))
    (define (test-and-set!)
      (if (car cell)
	  #t
	  (begin (set-car! cell #t)
		 #f)))
    (define (clear!)
      (set-car! cell #f))
    (define (acquire-count-lock)
      (if (test-and-set!)
	  (acquire-count-lock)))
    (define (release-count-lock)
      (clear!))
    (define (the-semaphore m)
      (cond ((eq? m 'acquire)
	     (acquire-count-lock)
	     (if (= count n)
		 (begin (release-count-lock)
			(the-semaphore 'acquire))
		 (begin (set! count (+ count 1))
			(release-count-lock))))
	    ((eq? m 'release)
	     (acquire-count-lock)
	     (if (> count 0)
		 (begin (set! count (- count 1))
			(release-count-lock))))))
    the-semaphore))

;; Exercise 3.48
;; 为资源加上编号，每次都从小编号开始加锁这个方法有效的原因
;; 在于将加锁的顺序固定，这样就不会出现两个线程同时为不同
;; 的分享变量加锁的情况了。
;; 代码略

;; Exercise 3.49
;; 假设A和B分别有一个帐号A-acc和B-acc，但是A和B都可以使用
;; 对方的帐号。假如某时刻，A和B在购物时发现自己帐号的钱不够，
;; 于是同时想要去取对方帐号里的钱，这是死锁现象又出现了。

;; delay and force
(define (memo-proc proc)
  (let ((already-run? #f)
	(result #f))
    (lambda ()
      (if (not already-run?)
	  (begin (set! result (proc))
		 (set! already-run? #t)
		 result)
	  result))))
(define-syntax my-delay
  (syntax-rules ()
    ((my-delay proc)
     (memo-proc (lambda () proc)))))
(define (my-force delayed-object)
  (delayed-object))

;; Must be a special form,
;; or a and b will be evaluated
;; when applying cons-stream.
(define-syntax cons-stream
  (syntax-rules ()
    ((cons-stream a b)
     (cons a (my-delay b)))))
(define (stream-car s)
  (car s))
(define (stream-cdr s)
  (my-force (cdr s)))
(define the-empty-stream '())
(define (stream-null? s)
  (null? s))

;; Streams
(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))
(define (stream-map proc s)
  (if (stream-null? s)
      the-empty-stream
      (cons-stream (proc (stream-car s))
		   (stream-map proc (stream-cdr s)))))
(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
	     (stream-for-each proc (stream-cdr s)))))

(define (display-stream s)
  (stream-for-each display-line s))
(define (display-line x)
  (newline)
  (display x))

(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream low
		   (stream-enumerate-interval (+ low 1) high))))
(define (stream-filter pred stream)
  (cond ((stream-null? stream) the-empty-stream)
	((pred (stream-car stream))
	 (cons-stream (stream-car stream)
		      (stream-filter pred (stream-cdr stream))))
	(else (stream-filter pred (stream-cdr stream)))))

;; Exercise 3.50
(define (stream-map-multi-streams proc . argstreams)
  (if (null? (car argstreams))
      the-empty-stream
      (cons-stream (apply proc (map stream-car argstreams))
		   (apply stream-map-multi-streams
			  (cons proc (map stream-cdr argstreams))))))

;; Exercise 3.51
(define (show x)
  (display-line x)
  x)
;; (define x
;;   (stream-map show
;; 	      (stream-enumerate-interval 0 10)))
;; => 0
;; (stream-ref x 5)
;; =>
;; 1
;; 2
;; 3
;; 4
;; 5
;; (stream-ref x 7)
;; =>
;; 6
;; 7

;; Exercise 3.52
(define sum 0)
(define (accum x)
  (set! sum (+ x sum))
  sum)
(define seq (stream-map accum
			(stream-enumerate-interval 1 20)))
(define y (stream-filter even? seq))
(define z
  (stream-filter (lambda (x) (= (remainder x 5) 0))
		 seq))
;; (stream-ref y 7)
;; => 137
;; (display-stream z)
;; =>
;; 10
;; 15
;; 45
;; 55
;; 105
;; 120
;; 190
;; 210
;; 如果将delay的实现改为无memo-proc的版本，那么结果必然是不同的。
;; memo-proc的作用是避免多次计算，同时保留计算结果，如果将memo-proc
;; 删去，则每次执行force都会重新计算被delay的对象的值，由于我们
;; 这里的delay过的对象是有副作用的，所以会导致sum的值不断被改变。

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))
(define integers (integers-starting-from 1))
(define (divisible? x y) (= (remainder x y) 0))
(define no-sevens
  (stream-filter (lambda (x) (not (divisible? x 7)))
		 integers))

(define (fibgen a b)
  (cons-stream a (fibgen b (+ a b))))
(define fibs (fibgen 0 1))

(define (sieve stream)
  (cons-stream
   (stream-car stream)
   (sieve (stream-filter
	   (lambda (x)
	     (not (divisible? x (stream-car stream))))
	   (stream-cdr stream)))))
(define primes (sieve (integers-starting-from 2)))

(define ones (cons-stream 1 ones))
(define (add-streams s1 s2) (stream-map-multi-streams + s1 s2))
(define integers
  (cons-stream 1 (add-streams ones integers)))

(define fibs
  (cons-stream
   0
   (cons-stream 1 (add-streams (stream-cdr fibs) fibs))))
(define (scale-stream stream factor)
  (stream-map (lambda (x) (* x factor))
	      stream))
(define double
  (cons-stream 1 (scale-stream double 2)))

(define primes
  (cons-stream
   2
   (stream-filter prime? (integers-starting-from 3))))
(define (prime? n)
  (define (iter ps)
    (cond ((> (square (stream-car ps)) n) #t)
	  ((divisible? n (stream-car ps)) #f)
	  (else (iter (stream-cdr ps)))))
  (iter primes))

;; Exercise 3.53
;; (define s (cons-stream 1 (add-streams s s)))
;; 上面的s会产生1 2 4 8 16 32 ...这样的序列

;; Exercise 3.54
(define (mul-stream s1 s2)
  (stream-map-multi-streams * s1 s2))
(define factorials
  (cons-stream 1 (mul-stream (stream-cdr integers) factorials)))

;; Exercise 3.55
(define (partial-sum stream)
  (cons-stream
   (stream-car stream)
   (add-streams (stream-cdr stream)
		(partial-sum stream))))

;; Exercise 3.56
(define (merge-stream s1 s2)
  (cond ((stream-null? s1) s2)
	((stream-null? s2) s1)
	(else
	 (let ((s1car (stream-car s1))
	       (s2car (stream-car s2)))
	   (cond ((< s1car s2car)
		  (cons-stream s1car
			       (merge-stream (stream-cdr s1) s2)))
		 ((> s1car s2car)
		  (cons-stream s2car
			       (merge-stream s1 (stream-cdr s2))))
		 (else
		  (cons-stream s1car
			       (merge-stream (stream-cdr s1)
					     (stream-cdr s2)))))))))
(define S (cons-stream 1 (merge-stream (scale-stream S 2)
				       (merge-stream (scale-stream S 3)
						     (scale-stream S 5)))))

;; Exercise 3.57
;; 使用了memo-proc之后，所有重复的计算都只需要计算一次，所以
;; 计算第n个fibonacci数只需要进行n-1次加法。如果我们不使用memo-proc
;; 所有的加法运算都需要执行，因而其计算次数有公式：N(n) = N(n-1)+N(n-2)+1
;; 这是一个指数增长的过程。

;; Exercise 3.58
(define (expand num den radix)
  (cons-stream
   (quotient (* num radix) den)
   (expand (remainder (* num radix) den) den radix)))
;; (expand 1 7 10)产生的是1.0/7.0的各位值，即1 4 2 8 ...
;; (expand 3 8 10)同上，它产生的是3 7 5 0 0 ...

;; Exercise 3.59
(define (integrate-series stream)
  (stream-map-multi-streams / stream integers))

(define exp-series
  (cons-stream 1 (integrate-series exp-series)))
(define cosine-series
  (cons-stream 1 (neg-stream (integrate-series sine-series))))
(define sine-series
  (cons-stream 0 (integrate-series cosine-series)))
(define (neg-stream s)
  (stream-map (lambda (x) (- x)) s))

;; Exercise 3.60
(define (mul-series s1 s2)
  (cons-stream
   (* (stream-car s1) (stream-car s2))
   (add-streams
    (scale-stream (stream-cdr s2) (stream-car s1))
    (mul-series (stream-cdr s1) s2))))

;; Exercise 3.61
(define (invert-unit-series s)
  (cons-stream
   1
   (neg-stream
    (mul-series
     (invert-unit-series s)
     (stream-cdr s)))))

;; Exercise 3.62
(define (div-series num denom)
  (let ((denomer (stream-car denom)))
    (if (zero? denomer)
	(error "DIV-SERIES" "cannot div by 0")
	(mul-series
	 (invert-unit-series
	  (scale-stream denom denomer))
	 num))))


;; formulating iterations as stream processes
(define (average x y)
  (/ (+ x y) 2))
(define (sqrt-improve guess x)
  (average guess (/ x guess)))
(define (sqrt-stream x)
  (define guesses
    (cons-stream
     1.0
     (stream-map-multi-streams (lambda (guess) (sqrt-improve guess x))
			       guesses)))
  guesses)

(define (pi-summands n)
  (cons-stream (/ 1.0 n)
	       (stream-map - (pi-summands (+ n 2)))))
(define pi-stream
  (scale-stream (partial-sum (pi-summands 1)) 4))

(define (euler-transform s)
  (let ((s0 (stream-ref s 0))
	(s1 (stream-ref s 1))
	(s2 (stream-ref s 2)))
    (cons-stream (- s2 (/ (square (- s2 s1))
			  (+ s0 (* -2 s1) s2)))
		 (euler-transform (stream-cdr s)))))

(define (make-tableau transform s)
  (cons-stream s (make-tableau transform (transform s))))
(define (accelerated-sequence transform s)
  (stream-map stream-car (make-tableau transform s)))

;; Exercise 3.63
;; (define (sqrt-stream x)
;;   (cons-stream 1.0 (stream-map
;; 		    (lambda (guess)
;; 		      (sqrt-improve guess x))
;; 		    (sqrt-stream x))))
;; 上面的实现效率的确要低。因为它又需要重复计算了。
;; sqrt-stream内部又需要计算sqrt-stream，但是它们并
;; 不是同一个stream，所以需要重复计算。一开始的实现
;; 通过guesses这一个stream来实现，避免了重复计算。
;; 如果将memo-proc取消的话，计算量应该是相同的。

;; Exercise 3.64
(define (stream-cadr s)
  (stream-car (stream-cdr s)))
(define (stream-limit s tolerance)
  (if (< (abs (-
	       (stream-car s)
	       (stream-cadr s)))
	 tolerance)
      (stream-cadr s)
      (stream-limit (stream-cdr s) tolerance)))
(define (sqrt1 x tolerance)
  (stream-limit (sqrt-stream x) tolerance))

;; Exercise 3.65
(define (ln2-summands n)
  (cons-stream (/ 1.0 n)
	       (stream-map - (ln2-summands (+ n 1)))))
(define ln2-stream
  (partial-sum (ln2-summands 1)))
;; 使用了accelerated-sqeuence之后进展更快


(define (stream-append s1 s2)
  (if (stream-null? s1)
      s2
      (cons-stream (stream-car s1)
		   (stream-append (stream-cdr s1) s2))))
(define (interleave s1 s2)
  (if (stream-null? s1)
      s2
      (cons-stream (stream-car s1)
		   (interleave s2 (stream-cdr s1)))))
(define (pairs s t)
  (cons-stream
   (list (stream-car s) (stream-car t))
   (interleave
    (stream-map (lambda (x) (list (stream-car s) x))
		(stream-cdr t))
    (pairs (stream-cdr s) (stream-cdr t)))))

;; Exercise 3.66
;; N(i, j) = 2^(i-1)(max(1, 2(j-i)+1)-2

;; Exercise 3.67
(define (show-stream s count)
  (display (stream-car s))
  (newline)
  (if (> count 0)
      (show-stream (stream-cdr s) (- count 1))))
(define (new-pairs s t)
  (cons-stream
   (list (stream-car s) (stream-car t))
   (interleave
    (stream-map (lambda (x) (list (stream-car s) x))
		(stream-cdr t))
    (interleave
     (stream-map (lambda (x) (list x (stream-car t)))
		 (stream-cdr s))
     (pairs (stream-cdr s) (stream-cdr t))))))

;; Exercise 3.68
;; (define (pairs s t)
;;   (interleave
;;    (stream-map (lambda (x) (list (stream-car s) x))
;; 	       t)
;;    (pairs (stream-cdr s) (stream-cdr t))))
;; 这个函数在调用(pairs integers integers)会导致无限递归
;; interleave和pairs会被不断调用。原先的调用使用了
;; cons-stream来延迟了interleave的调用。

;; Exercise 3.69
(define (triples s t u)
  (cons-stream
   (list (stream-car s) (stream-car t) (stream-car u))
   (interleave
    (stream-map (lambda (x) (cons (stream-car s) x))
		(pairs t (stream-cdr u)))
    (triples (stream-cdr s) (stream-cdr t) (stream-cdr u)))))
(define tri (triples integers integers integers))
(define (pythagorean? l)
  (= (+ (square (car l))
	(square (cadr l)))
     (square (caddr l))))
(define pythagorean-tri (stream-filter pythagorean? tri))

;; Exercise 3.70
(define (merge-weighted s1 s2 weight)
  (cond ((stream-null? s1) s2)
	((stream-null? s2) s1)
	(else
	 (let ((s1car (stream-car s1))
	       (s2car (stream-car s2)))
	   (if (<= (weight s1car) (weight s2car))
	       (cons-stream s1car (merge-weighted (stream-cdr s1) s2 weight))
	       (cons-stream s2car (merge-weighted s1 (stream-cdr s2) weight)))))))
(define (weighted-pairs s t weight)
  (cons-stream
   (list (stream-car s) (stream-car t))
   (merge-weighted
    (stream-map (lambda (x) (list (stream-car s) x))
		(stream-cdr t))
    (weighted-pairs (stream-cdr s) (stream-cdr t) weight)
    weight)))
(define stream-a (weighted-pairs integers
				 integers
				 (lambda (x)
				   (+ (car x) (cadr x)))))
(define stream-235
  (stream-filter (lambda (x)
		   (and (not (divisible? x 2))
			(not (divisible? x 3))
			(not (divisible? x 5))))
		 integers))
(define stream-b
  (weighted-pairs stream-235
		  stream-235
		  (lambda (x)
		    (+ (* 2 (car x))
		       (* 3 (cadr x))
		       (* 5 (car x) (cadr x))))))

;; Exercise 3.71
(define (cube x)
  (* x x x))
(define (ram-weight p)
  (+ (cube (car p))
     (cube (cadr p))))
(define stream-cubes
  (weighted-pairs integers
		  integers
		  ram-weight))
(define (search-ramanujan-numbers pairs)
  (let ((w1 (ram-weight (stream-car pairs)))
	(w2 (ram-weight (stream-cadr pairs))))
    (if (= w1 w2)
	(cons-stream w1 (search-ramanujan-numbers (stream-cdr pairs)))
	(search-ramanujan-numbers (stream-cdr pairs)))))
(define ramanujan-numbers
  (search-ramanujan-numbers stream-cubes))
;; 1729, 4104, 13832, 20683, 32832, 39312

;; Exercise 3.72
(define (square-weight p)
  (+ (square (car p))
     (square (cadr p))))
(define stream-squares
  (weighted-pairs integers
		  integers
		  square-weight))
(define (search-ex-3-72 pairs)
  (let* ((w1 (square-weight (stream-car pairs)))
	 (rest-of-pairs (stream-cdr pairs))
	 (w2 (square-weight (stream-car rest-of-pairs)))
	 (rest-of-rest-of-pairs (stream-cdr rest-of-pairs))
	 (w3 (square-weight (stream-car rest-of-rest-of-pairs))))
    (cond ((= w1 w2 w3)
	   (newline)
	   (display (stream-car pairs))
	   (newline)
	   (display (stream-car rest-of-pairs))
	   (newline)
	   (display (stream-car rest-of-rest-of-pairs))
	   (cons-stream w1 (search-ex-3-72 (stream-cdr rest-of-rest-of-pairs))))
	  ((= w2 w3)
	   (search-ex-3-72 rest-of-pairs))
	  (else
	   (search-ex-3-72 rest-of-rest-of-pairs)))))
(define ex-3-72-stream
  (search-ex-3-72 stream-squares))

(define (integral integrand initial-value dt)
  (define int
    (cons-stream initial-value
		 (add-streams (scale-stream integrand dt)
			      int)))
  int)

;; Exercise 3.73
(define (RC R C dt)
  (lambda (i v0)
    (add-streams (integral (scale-stream ones (/ 1.0 C)) v0 dt)
		 (scale-stream i R))))

;; Exercise 3.74
(define sense-data integers)
(define (sign-change-detector new old)
  (cond ((and (< old 0) (> new 0))
	 1)
	((and (> old 0) (< new 0))
	 -1)
	(else 0)))
(define (make-zero-crossings input-stream last-value)
  (cons-stream
   (sign-change-detector
    (stream-car input-stream)
    last-value)
   (make-zero-crossings
    (stream-cdr input-stream)
    (stream-car input-stream))))
(define zero-crossings
  (make-zero-crossings
   sense-data 0))
(define zero-crossings
  (stream-map-multi-streams sign-change-detector
			    sense-data
			    (cons-stream 0 sense-data)))

;; Exercise 3.75
;; (define (make-zero-crossings input-stream last-value)
;;   (let ((avpt (/ (+ stream-car input-stream)
;; 		 last-value)
;; 	      2)))
;;   (cons-stream
;;    (sign-change-detector avpt last-value)
;;    (make-zero-crossings
;;     (stream-cdr input-stream) avpt)))

;; (define (make-zero-crossings input-stream last-value last-avpt)
;;   (let ((avpt (/ (+ stream-car input-stream)
;; 		 last-value)
;; 	      2)))
;;   (cons-stream
;;    (sign-change-detector avpt last-avpt)
;;    (make-zero-crossings
;;     (stream-cdr input-stream)
;;     (stream-car input-stream)
;;     avpt)))

;; Exercise 3.75
(define (smooth input-stream)
  (let ((avpt (average (stream-car input-stream)
		       (stream-cadr input-stream))))
    (cons-stream avpt
		 (smooth (stream-cdr input-stream)))))

;; delayed evaluation
(define (integral2 delayed-integrand initial-value dt)
  (define int
    (cons-stream
     initial-value
     (let ((integrand (force delayed-integrand)))
       (add-streams (scale-stream integrand dt) int))))
  int)
(define (solve f y0 dt)
  (define y (integral2 (delay dy) y0 dt))
  (define dy (stream-map f y))
  y)

;; Exercise 3.77
(define (integral3 delayed-integrand initial-value dt)
  (cons-stream initial-value
	       (let ((integrand (force delayed-integrand)))
		 (if (stream-null? integrand)
		     the-empty-stream
		     (integral3 (delay (stream-cdr integrand))
				(+ (* dt (stream-car integrand))
				   initial-value)
				dt)))))

;; Exercise 3.78
(define (solve-2nd a b dt y0 dy0)
  (define y (integral2 (delay dy) y0 dt))
  (define dy (integral2 (delay ddy) dy0 dt))
  (define ddy (add-streams (scale-stream dy a)
			   (scale-stream y b)))
  y)

;; Exercise 3.79
(define (solve-2nd-general f dt y0 dy0)
  (define y (integral2 (delay dy) y0 dt))
  (define dy (integral2 (delay ddy) dy0 dt))
  (define ddy (stream-map f dy y))
  y)

;; Exercise 3.80
(define (RLC R L C dt)
  (lambda (vC0 iL0)
    (define vC (integral2 (delay dvC) vC0 dt))
    (define iL (integral2 (delay diL) iL0 dt))
    (define dvC (scale-stream iL (/ -1.0 C)))
    (define diL (add-streams (scale-stream vC (/ 1.0 L))
			     (scale-stream iL (/ (- R) L))))
    (stream-map-multi-streams (lambda (x1 x2)
				(cons x1 x2))
			      vC iL)))


(define random-init 137)
(define (rand-update x)
  (let ((a (expt 2 32))
	(c 1103515245)
	(m 12345))
    (modulo (+ (* a x) c) m)))
(define random-numbers
  (cons-stream
   random-init
   (stream-map rand-update random-numbers)))
(define (map-successive-pairs f s)
  (cons-stream
   (f (stream-car s) (stream-cadr s))
   (map-successive-pairs f (stream-cdr (stream-cdr s)))))
(define cesaro-stream
  (map-successive-pairs
   (lambda (r1 r2) (= (gcd r1 r2) 1))
   random-numbers))

(define (monte-carlo experiment-stream passed failed)
  (define (next passed failed)
    (cons-stream
     (/ passed (+ passed failed))
     (monte-carlo
      (stream-cdr experiment-stream) passed failed)))
  (if (stream-car experiment-stream)
      (next (+ passed 1) failed)
      (next passed (+ failed 1))))
(define pi
  (stream-map-multi-streams
   (lambda (p) (sqrt (/ 6 p)))
   (monte-carlo cesaro-stream 0 0)))

;; Exercise 3.81
(define (random-numbers-proc stream-in)
  (define (action x m)
    (cond ((eq? m 'generate)
	   (rand-update x))
	  (else m)))
  (cons-stream random-init
	       (stream-map-multi-streams action (random-numbers-proc stream-in) stream-in)))
(define test-stream-1 (cons-stream 'generate test-stream-1))
(define test-stream-2 (cons-stream 'generate
				   (cons-stream 237
						(cons-stream 'generate test-stream-1))))

;; Exercise 3.82
(define (generate-random-in-range low high)
  (cons-stream (+ low (random (- high low)))
	       (generate-random-in-range low high)))
(define (generate-integral-stream pred x1 x2 y1 y2)
  (stream-map-multi-streams pred
			    (generate-random-in-range x1 x2)
			    (generate-random-in-range y1 y2)))
(define (estimate-integral-stream pred x1 x2 y1 y2)
  (scale-stream (monte-carlo (generate-integral-stream pred x1 x2 y1 y2) 0 0)
		(* (- x2 x1) (- y2 y1))))
