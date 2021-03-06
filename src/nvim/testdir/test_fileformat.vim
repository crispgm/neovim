" Test behavior of fileformat after bwipeout of last buffer

func Test_fileformat_after_bw()
  bwipeout
  set fileformat&
  if &fileformat == 'dos'
    let test_fileformats = 'unix'
  elseif &fileformat == 'unix'
    let test_fileformats = 'mac'
  else  " must be mac
    let test_fileformats = 'dos'
  endif
  exec 'set fileformats='.test_fileformats
  bwipeout!
  call assert_equal(test_fileformats, &fileformat)
  set fileformats&
endfunc

func Test_fileformat_autocommand()
  let filecnt = ["", "foobar\<CR>", "eins\<CR>", "\<CR>", "zwei\<CR>", "drei", "vier", "fünf", ""]
  let ffs = &ffs
  call writefile(filecnt, 'Xfile', 'b')
  au BufReadPre Xfile set ffs=dos ff=dos
  new Xfile
  call assert_equal('dos', &l:ff)
  call assert_equal('dos', &ffs)

  " cleanup
  call delete('Xfile')
  let &ffs = ffs
  au! BufReadPre Xfile
  bw!
endfunc

" Test for changing the fileformat using ++read
func Test_fileformat_plusplus_read()
  new
  call setline(1, ['one', 'two', 'three'])
  w ++ff=dos Xfile1
  enew!
  set ff=unix
  " A :read doesn't change the fileformat, but does apply to the read lines.
  r ++fileformat=unix Xfile1
  call assert_equal('unix', &fileformat)
  call assert_equal("three\r", getline('$'))
  3r ++edit Xfile1
  call assert_equal('dos', &fileformat)
  close!
  call delete('Xfile1')
  set fileformat&
  call assert_fails('e ++fileformat Xfile1', 'E474:')
  call assert_fails('e ++ff=abc Xfile1', 'E474:')
  call assert_fails('e ++abc1 Xfile1', 'E474:')
endfunc

" vim: shiftwidth=2 sts=2 expandtab
