def test_sistema():
    from io import StringIO
    import sys

    input_backup = sys.stdin
    sys.stdin = StringIO('1\nEstudar POO\n4\n6\n') 
    from to_do_list import main
    main()  

    sys.stdin = input_backup
    
