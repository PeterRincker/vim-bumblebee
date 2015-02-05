if exists('g:loaded_bumblebee') || &cp || v:version < 700
	finish
endif
let g:loaded_bumblebee = 1

function! s:buffer_complete(lead, cmdline, _) abort
  let bufnr = bufnr('%')
  let buffers = s:get_buffers('v:val != '.bufnr.' && bufloaded(v:val) && buflisted(v:val)')

  let filtered = s:complete_filter(filter(buffers, 'v:val =~ ''^[^~'.s:slash().']'''), a:lead)
  if empty(filtered)
    let filtered = s:complete_filter(buffers, a:lead)
  endif
  if empty(filtered)
    let filtered = s:complete_filter(s:get_buffers('buflisted(v:val)'), a:lead)
  endif

  return sort(filtered, 's:cmp_by_length')
endfunction

function! s:complete_filter(results, A)
  let sep = s:slash()
  let results = s:uniq(sort(copy(a:results)))
  call filter(results,'v:val !~# "\\~$"')

  let filtered = filter(copy(results),'v:val[0:strlen(a:A)-1] == a:A')
  if !empty(filtered) | return filtered | endif

  let regex = s:gsub(a:A,'[^'.sep.']','[&][^'.sep.']*')
  let filtered = filter(copy(results),'v:val =~ regex."$"')
  if !empty(filtered) | return filtered | endif

  let regex = s:gsub(a:A,'[^'.sep.']','[&].*')
  let filtered = filter(copy(results),'v:val =~ "^".regex')

  if !empty(filtered) | return filtered | endif
  let filtered = filter(copy(results),'sep.v:val =~ ''['.sep.']''.regex')

  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'.','[&].*')
  let filtered = filter(copy(results),'v:val =~ regex')

  return filtered
endfunction

function! s:get_buffers(expr)
  return map(filter(range(1, bufnr('$')), a:expr), 'fnamemodify(bufname(v:val), ":~:.")')
endfunction

function! s:cmp_by_length(...)
	let [len1, len2] = [strlen(a:1), strlen(a:2)]
	return len1 == len2 ? 0 : len1 > len2 ? 1 : -1
endf

function! s:slash() abort
  return exists('+shellslash') && !&shellslash ? '\' : '/'
endfunction

function! s:open_buffer(bang, cmd, key)
  try
    let key = a:key
    if key != '#' && key !~ '^\d\+$'
      let lst = s:buffer_complete(key, '', '')
      if len(lst) == 0
        call s:throw("No matching buffers")
        return
      elseif len(lst) > 1
        call s:throw("More than one match for " . a:key)
      endif
      let key = lst[0]
    endif
    return  a:cmd . a:bang . ' ' . key
  catch /^bumblebee:/
    return 'echoerr v:errmsg'
  endtry
endfunction

function! s:throw(string) abort
  let v:errmsg = 'bumblebee: '.a:string
  throw v:errmsg
endfunction

function! s:gsub(str, pat, repl) abort
  return substitute(a:str, '\v\C'.a:pat, a:repl, 'g')
endfunction

function! s:uniq(list) abort
  if exists('*uniq')
    return uniq(a:list)
  endif
  let i = 0
  let seen = {}
  while i < len(a:list)
    let str = string(a:list[i])
    if has_key(seen, str)
      call remove(a:list, i)
    else
      let seen[str] = 1
      let i += 1
    endif
  endwhile
  return a:list
endfunction

function! s:exabbrev(lhs, ...)
  let rhs = substitute(join(a:000, ' '), "'", "''", 'g')
  execute 'cnoreabbrev <expr> ' . a:lhs . ' getcmdtype() == ":" && getcmdline() ==# "' . a:lhs . '" ? expand(''' . rhs . ''') : "' . a:lhs . '"'
endfunction

command! -nargs=1 -bar -bang -complete=customlist,s:buffer_complete B execute s:open_buffer('<bang>', 'b', <f-args>)
command! -nargs=1 -bar -bang -complete=customlist,s:buffer_complete Sb execute s:open_buffer('<bang>', 'sb', <f-args>)
command! -nargs=1 -bar -bang -complete=customlist,s:buffer_complete Vb execute s:open_buffer('<bang>', 'vert sb', <f-args>)

if !get(g:, 'bumblebee_no_abbreviations', 0)
  call s:exabbrev('b', 'B')
  call s:exabbrev('sb', 'Sb')
  call s:exabbrev('vb', 'Vb')
endif
