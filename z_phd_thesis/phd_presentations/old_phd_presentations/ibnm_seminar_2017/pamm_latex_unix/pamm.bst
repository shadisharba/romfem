%%% BibTeX bibliography style `pamm'
%%% for BibTeX versions 0.99a+ and LaTeX2e.
%%% --------------------------------------------------------
%%% A BibTeX style for WILEY-VCH Verlag Berlin, for 
%%% Proceedings in Applied Mathematics and Mechanics (PAMM)
%%% by Martin Wilhelm Leidig <Martin.Leidig@onlinehome.de>, 
%%% to support Wiley/VCH's up-to-date referencing style.
%%% 
%%% This BibTeX style
%%% -- uses numerical cite labels,
%%% -- omits journal titles, and
%%% -- outputs entries in the sequence of their citation.
%%% 
%%% -MWL- V 0.3 2007-04-11
%%%   
ENTRY
  { address
    author
    booktitle
    chapter
    edition
    editor
    howpublished
    institution
    journal
    key
    month
    note
    number
    organization
    pages
    publisher
    school
    series
    title
    type
    volume
    year
  }
  {}
  { label }

INTEGERS { output.state before.all mid.sentence after.sentence 
		   after.block mid.names after.names 
		   put.comma put.point add.period relax }

FUNCTION {init.state.consts}
%%% bestimmt, was output.nonnull mit naechster Ausgabe macht
{ % 
  #0 'before.all :=		% 
  #1 'mid.sentence :=	% 
  #2 'after.sentence :=	% 
  #3 'after.block :=	% 
  #4 'mid.names :=		% 
  #5 'after.names :=	% 
  #1 'put.comma :=		% Komma anhaengen
  #3 'put.point :=		% Punkt anhaengen
  #2 'add.period :=		% dito, ggf. Satzzeichen entfernen
  #0 'relax :=			% nichts anhaengen
}

%%% generic prefixes -MWL- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
FUNCTION {f.author.name}	{" \textsc"}	% author names
FUNCTION {f.editor.name}	{""}	% editor names
FUNCTION {f.title}			{""}	
FUNCTION {f.btitle}			{""}	% in format.btitle
FUNCTION {f.journal}		{" \jr"}% in article
FUNCTION {f.bseries}    	{""}	% in format.bvolume and
% 									%    format.book.crossref
FUNCTION {f.series}			{""}	% in format.number.series
FUNCTION {f.edition}		{""}	% in format.edition
FUNCTION {f.art.volume}		{" \textbf"}	% in format.vol.year.num.pages
FUNCTION {f.bktitle}    	{""}	% in format.in.ed.booktitle and
% 									%    format.incoll.inproc.crossref
FUNCTION {f.cr.journal} 	{""}	% in format.article.crossref
FUNCTION {f.date}			{""}	% in format.date
FUNCTION {f.publ}			{""}	% publisher in book, booklet..
FUNCTION {f.addr}			{""}	% adresse in book, booklet..
FUNCTION {f.org}			{""}	% organization
FUNCTION {f.school}			{""}	% school in masterthesis
FUNCTION {f.note}			{""}	% note
%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 
FUNCTION {str.in}		{" in: "}	%
FUNCTION {str.and}		{" and "}	%
FUNCTION {str.Vol}		{" Vol.\,"}	%
FUNCTION {str.p}		{" p.\,"}	%
FUNCTION {str.pp}		{" pp.\,"}	%
FUNCTION {str.etal}		{" \etal{}"}%
FUNCTION {str.others}	{"others"}%
FUNCTION {str.comma}	{", "}	%
FUNCTION {str.point}	{"."}	%
%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

STRINGS { s t }

FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence = 		% Satzmitte?
    { str.comma * write$ } 			% T  
    { output.state after.block = 	% F; Block beendet?
	  { str.comma * write$ 	 			%T; "," statt "."
		newline$
		mid.sentence 'output.state :=
	  }
      { output.state mid.names = 		% F; innerhalb Namen?
        { write$ } 			 		 		% T --> ausgeben
		{ output.state after.names = 		% F; nach Namen?
		  { str.comma * 			 			% T; "," statt ":"
            write$			 				 	% ausgeben
			newline$
		  }
		  { output.state before.all =				% F; am Anfang?
			  {}						 			% T
              { str.comma * }				 		% F --> Komma
            if$ write$				 			% ausgeben
		  }
	    if$
        mid.sentence 'output.state :=
		}
	  if$
	  }
	if$
	}
  if$
  s
}

FUNCTION {reset.state}
{ before.all 'output.state := }

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty <" t "> in " * * 
      "@" type$ "{" * * * % -MWL- 2007-03-02
      cite$ "}" * * 
      warning$ }
    'output.nonnull
  if$
}

FUNCTION {output.bibitem.journal}	% Journal: ohne \othercit
{ newline$
  "\bibitem{" write$
  cite$ write$
  "}% " type$ * write$
  newline$
  ""
  before.all 'output.state :=
}

FUNCTION {output.bibitem.other}	% "normale" Eintraege mit \othercit
{ newline$
  "\othercit" write$
  output.bibitem.journal	% -MWL-
}

FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
  newline$	% -MWL- eine Leerzeile wg. Uebersichtlichkeit
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { output.state mid.names =
       { after.names 'output.state := } 
       { after.block 'output.state := }
      if$
    }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
	    'skip$
	  { after.sentence 'output.state := }
      if$
    }
  if$
}

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}

FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}

FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {string.prefix}	% -MWL- call: string prefix string.prefix
% Output: "prefixstring"
{ duplicate$ empty$		% prefix empty?
    'pop$
    { swap$ duplicate$ empty$	% string empty?
        { pop$ pop$ "" }
        { * 	% "prefixstring"
        }
      if$
    }
  if$
}

FUNCTION {string.prefix.command}	% -MWL- call: string prefix string.prefix.command
% Output: "prefix{string}"
{ duplicate$ empty$		% prefix empty?
    'pop$
    { swap$ duplicate$ empty$	% string empty?
        { pop$ pop$ "" }
        { swap$			% stack: string prefix (again)
        "{" * swap$ * "}" *	% "prefix{string}"
        }
      if$
    }
  if$
}

FUNCTION {string.disable}	% -MWL- call: string string.disable
% Output: "\iffalse string\fi"
{ duplicate$ empty$
    { pop$ "" }
    { "\iffalse " swap$ * "\fi" * 
      before.all 'output.state :=  % n\"achstes Komma unterdr\"ucken
      }
  if$
}

INTEGERS { nameptr namesleft numnames }

FUNCTION {format.editor.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{f{.\,}.~}{vv{\,}~}{ll}{jj.}" format.name$ 't :=
      t str.others =
        'skip$
        { t f.editor.name string.prefix.command 't := }
      if$
      nameptr #1 >	% 
        { namesleft #1 >	% ist der letzte Name _nicht_ erreicht?
          {	str.comma * t * }	% ja: normales Trennzeichen, fertig
          { t str.others =		% nein: t = letzter Name; gekuerzte Liste?
            { str.etal * }		% ja: "\etal" statt "et~al."
            { numnames #2 =			% nein: _zwei_ Namen?
              { }						% ja
              { str.comma * }			% nein: Komma einfuegen
            if$
            str.and * t *			%  " and " einfuegen
            }
          if$
          }
       if$
       }
      't
    if$
    nameptr #1 + 'nameptr :=		% INC nameptr
    namesleft #1 - 'namesleft :=	% DEC namesleft
    }
  while$
  mid.names 'output.state :=
}

FUNCTION {format.author.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{f{.\,}.~}{vv{\,}~}{ll}{jj.}" format.name$ 't :=
      t str.others =
        'skip$
        { t f.author.name string.prefix.command 't := }
      if$
      nameptr #1 >	% 
        { namesleft #1 >	% ist der letzte Name _nicht_ erreicht?
          { str.comma * t * }	% ja: normales Trennzeichen, weiter
          { t str.others =		% nein: t = letzter Name; gekuerzte Liste?
            { str.etal * }		% ja: "\etal" statt "et~al."
            { numnames #2 =			% nein: _zwei_ Namen?
              { }						% ja 
              { str.comma * }			% nein: Komma einfuegen
            if$
            str.and * t *			% -MWL- " and " anfuegen
            }
          if$
          }
        if$
        }
      't
    if$
    nameptr #1 + 'nameptr :=		% INC nameptr
    namesleft #1 - 'namesleft :=	% DEC namesleft
    }
  while$
  mid.names 'output.state :=
}

FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.author.names }
  if$
}

FUNCTION {format.inbook.editors}	% -MWL- 
%%% Editor(s) of a book from which some author's part is cited
%%% "edited by <editor>"
{ editor empty$
    { "" }	%
    { %newline$
      "edited by " editor format.editor.names * }
  if$
}

FUNCTION {format.book.editors} % -MWL-
%%% Editor(s) of a whole book
%%% "<editor> (ed[s].)"
{ editor empty$
    { "" }	%
    { editor format.author.names
      editor num.names$ #1 >
        { " (eds.)" * }
        { " (ed.)" * }
      if$
    }
  if$
}

FUNCTION {str.CR} % -MWL- 2007-03-05
% pushes ASCII #13
{ #13 int.to.chr$ * }

FUNCTION {format.article.title} %  -MWL- 2007-03-04
{ title empty$
    { "" }
    { title f.title string.prefix "t" change.case$ 
      string.disable % -MWL- 2007-03-09
    }
  if$
}

FUNCTION {format.title}
{ title empty$
    { "" }
    { title f.title string.prefix.command "t" change.case$ }
  if$
}

FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
	{ t #1 #2 substring$ "--" = not
	    { "--" *
	      t #2 global.max$ substring$ 't :=
	    }
	    {   { t #1 #1 substring$ "-" = }
		{ "-" *
		  t #2 global.max$ substring$ 't :=
		}
	      while$
	    }
	  if$
	}
	{ t #1 #1 substring$ *
	  t #2 global.max$ substring$ 't :=
	}
      if$
    }
  while$
}

FUNCTION {format.date}
{ year empty$
    { month empty$
	{ "" }
	{ "there's a month but no year in " cite$ * warning$
	  month
	}
      if$
    }
    { month empty$
	'year
	{ month " " * year * }
      if$
    }
  if$
  f.date string.prefix.command
}

FUNCTION {format.btitle}
{ title f.btitle string.prefix.command		%% changed from emphasize
}

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #4 <	% -MWL- 
    { "~" }
    { " " }
  if$
  swap$ * *
}

FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

FUNCTION {format.bvolume}
{ volume empty$
  { "" }
  { series empty$
    'skip$
    { str.comma * series f.bseries string.prefix.command *	% statt ". "
      str.vol volume *		%
    }
  if$
  "volume and number" number either.or.check
  }
if$
}

FUNCTION {format.number.series}
{ volume empty$
    { number empty$
	{ series field.or.null }
        { output.state mid.sentence =
             { "No." }
             { "No." }
          if$
          number tie.or.space.connect
          series empty$
	    { "there's a number but no series in " cite$ * warning$ }
            { " in " * series f.series string.prefix.command *}   
	  if$
        }
      if$
    }
    { "" }
  if$
}

FUNCTION {format.edition}
{ edition empty$
    { "" }
    { edition
      output.state mid.sentence =
	{ "l" }
	{ "t" }
      if$
      change.case$ " edition" *
      f.edition string.prefix.command 
    }
  if$
}

INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
	{ #1 'multiresult := }
	{ t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}

FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
%         { "pp." pages n.dashify tie.or.space.connect }
%         { "p." pages tie.or.space.connect }
        { str.pp pages n.dashify * }
        { str.p pages * }
      if$
    }
  if$
}

FUNCTION {format.vol.num.pages}
{ volume field.or.null
  number empty$
    'skip$
    { "(" number * ")" * *
      volume empty$
	{ "there's a number but no volume in " cite$ * warning$ }
	'skip$
      if$
    }
  if$
  pages empty$
    'skip$
    { duplicate$ empty$
	{ pop$ format.pages }
	{ ":" * pages n.dashify * }
      if$
    }
  if$
}

FUNCTION {format.vol.year.num.pages}
% -MWL-  changed to produce "\textbf{volume}(number|month), pages (year)"
{ volume empty$
    {""}
    {volume f.art.volume string.prefix.command}
  if$
  number empty$
    { month empty$
        'skip$
        { "(" * month * ")" * }
      if$
    }
    { "(" * number * ")" * }
  if$  
  pages empty$
    'skip$
    { duplicate$ empty$
        { pop$ format.pages }
        { str.comma * pages n.dashify * }
      if$
    }
  if$
  year empty$
    'skip$
    { " (" * year * ")" * }
  if$
}

FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
      { "chap." }					% -MWL- abbreviation changed
      { type "l" change.case$ 
		duplicate$ "section" =
		  { pop$ "sect." }
		  { duplicate$ "chapter" =
		    { pop$ "chap." }
			'skip$
		  if$
		  }
		if$
		}
      if$
      chapter tie.or.space.connect
      pages empty$
	'skip$
	{ str.comma * format.pages * }
      if$
    }
  if$
}

FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { str.in output.nonnull reset.state ""
      booktitle f.bktitle string.prefix.command * str.comma *	% title first
      editor empty$
	    'skip$
	    { format.inbook.editors * 
%         output.nonnull
% 	      new.block
% 		  " " 
        }
      if$
%       booktitle f.bktitle string.prefix.command * str.comma *	% title first
     }
  if$
}

FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and
  key empty$ not and
    { "all relevant fields are empty in " cite$ * warning$ }
    'skip$
  if$
}

FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      type "t" change.case$
    }
  if$
}

FUNCTION {format.tr.number}
{ type empty$
    { "Tech. Rep." }                              % abbreviated
    'type
  if$
  number empty$
    { "t" change.case$ }
    { number tie.or.space.connect }
  if$
}

FUNCTION {format.article.crossref}
{ key empty$
  { journal empty$
    { "need key or journal for " cite$ * " to crossref " * crossref *
       warning$
	   ""
    }
    { str.in journal f.cr.journal string.prefix.command * }
  if$
  }
  { str.in key * }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {format.crossref.editor}
{ editor #1 "{vv\,}{ll}" format.name$
  editor num.names$ duplicate$
  #2 >
    { pop$ " et~al." * }
    { #2 <
	'skip$
	{ editor #2 "{ff }{vv\,}{ll}{ jj}" format.name$ str.others =
	    { " et~al." * }
	    { str.and * editor #2 "{vv\,}{ll}" format.name$ * }
	  if$
	}
      if$
    }
  if$
}


FUNCTION {format.book.crossref}
{ volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$
      str.in
    }
    { str.Vol volume tie.or.space.connect
      " of " *
    }
  if$
  editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
	{ series empty$
	    { "need editor, key, or series for " cite$ * 
	      " to crossref " *
	      crossref * warning$
	      "" *
	    }
	    { series f.bseries string.prefix.command * }
	  if$
	}
	{ key * }
      if$
    }
    { format.crossref.editor * }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {format.incoll.inproc.crossref}
{ editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
	{ booktitle empty$
	    { "need editor, key, or booktitle for " cite$ * 
	      " to crossref " *  crossref * warning$
	      ""
	    }
	    { str.in booktitle f.bktitle string.prefix.command * }
	  if$
	}
	{ str.in key * }
      if$
    }
    { str.in format.crossref.editor * }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {article}
{ output.bibitem.journal	% -MWL-
  format.authors "author" output.check
  new.block
  format.article.title "title" output.check
  new.block
  crossref missing$
    { journal f.journal string.prefix.command
	  "journal" output.check
      reset.state
	  format.vol.year.num.pages output		% changed
%      format.date "year" output.check
    }
    { format.article.crossref output.nonnull
      format.pages output
    }
  if$
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {book}
{ output.bibitem.other	% -MWL-
  author empty$
    { format.book.editors "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
      { "author and editor" editor either.or.check }
        'skip$
      if$
      }
  if$
  new.block
  format.btitle "title" output.check
  format.edition output
  crossref missing$
    { format.bvolume output
%       new.block
      format.number.series output
%       new.sentence
	  reset.state
	  " (" publisher * f.publ string.prefix.command "publisher" output.check
      address f.addr string.prefix.command output
	  format.date ")" * "year" output.check
    }
    { new.block
      format.book.crossref output.nonnull
	  format.date "year" output.check
    }
  if$
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {booklet}
{ output.bibitem.other	% -MWL-
  format.authors output
  new.block
  format.title "title" output.check
  howpublished address new.block.checkb
  howpublished f.addr string.prefix.command output
  address f.addr string.prefix.command output
  format.date output
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {inbook}
{ output.bibitem.other	% -MWL-
  author empty$
    { format.book.editors "author and editor" output.check }
    { format.authors output.nonnull
%       crossref missing$
%       { "author and editor" editor either.or.check }
%         'skip$
%       if$
    }
  if$
  new.block
  title missing$
      'skip$
    { "in: " format.btitle *
      "title" output.check
    }
  if$
  format.edition output
  editor missing$
      'skip$
    { str.comma format.inbook.editors * *
    }
  if$
  crossref missing$
    { format.bvolume *
%     output
      new.block
      format.number.series *
%       output
%       new.sentence
	  reset.state
      " (" publisher * f.publ string.prefix.command "publisher" output.check
      address f.addr string.prefix.command output
      format.date ")" * "year" output.check
    }
    { new.block
      format.book.crossref output.nonnull
      format.date "year" output.check
    }
  if$
%   format.date "year" output.check
  format.chapter.pages "chapter and pages" output.check     % umgestellt
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {incollection}
{ output.bibitem.other	% -MWL-
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.check
      format.bvolume output
      format.number.series output
      format.edition output
%       new.sentence
	  reset.state
	  " (" publisher * f.publ string.prefix.command "publisher" output.check
      address f.addr string.prefix.command output
      format.date ")" * "year" output.check
      format.chapter.pages output                           % umgestellt
    }
    { format.incoll.inproc.crossref output.nonnull
      format.chapter.pages output
    }
  if$
  new.block
  note f.note string.prefix.command output
  fin.entry
}

% FUNCTION {inproceedings}{incollection}

FUNCTION {inproceedings}
{ output.bibitem.other	% -MWL-
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  crossref missing$
    { format.in.ed.booktitle "booktitle" output.check
      format.bvolume output
      format.number.series output
      format.edition output
%       new.sentence
	  reset.state
	  " (" * publisher  f.publ string.prefix.command "publisher" output.check
      address f.addr string.prefix.command output
      format.date ")" * "year" output.check
      format.chapter.pages output                           % umgestellt
    }
    { format.incoll.inproc.crossref output.nonnull
      format.chapter.pages output
    }
  if$
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {conference} { inproceedings }

FUNCTION {manual}
{ output.bibitem.other	% -MWL-
  author empty$
    { organization empty$
	'skip$
	{ organization output.nonnull
	  address output
	}
      if$
    }
    { format.authors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  author empty$
    { organization empty$
	{ address new.block.checka
	  address f.addr string.prefix.command output
	}
	'skip$
      if$
    }
    { organization address new.block.checkb
      organization f.org string.prefix.command output
      address f.addr string.prefix.command output
    }
  if$
  format.edition output
  format.date output
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {mastersthesis}
{ output.bibitem.other	% -MWL-
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  "Master's thesis" format.thesis.type output.nonnull
  school f.school string.prefix.command "school" output.check
  address f.addr string.prefix.command output
  format.date "year" output.check
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {misc}
{ output.bibitem.other	% -MWL-
  format.authors output
  title howpublished new.block.checkb
  format.title output
  howpublished new.block.checka
  howpublished output
  format.date output
  new.block
  note f.note string.prefix.command output
  fin.entry
  empty.misc.check
}

FUNCTION {phdthesis}
{ output.bibitem.other	% -MWL-
  format.authors "author" output.check
  new.block
  format.btitle "title" output.check
  new.block
  "PhD thesis" format.thesis.type output.nonnull
  school f.school string.prefix.command "school" output.check
  address f.addr string.prefix.command output
  format.date "year" output.check
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {proceedings}
{ output.bibitem.other	% -MWL-
  editor empty$
    { organization output }
    { format.book.editors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  format.bvolume output
  format.number.series output
  address empty$
    { editor empty$
	{ publisher new.sentence.checka }
	{ organization publisher new.sentence.checkb
	  organization f.org string.prefix.command output
	}
      if$
      publisher f.publ string.prefix.command output
      format.date "year" output.check
    }
    { address output.nonnull
      format.date "year" output.check
      new.sentence
      editor empty$
	'skip$
	{ organization f.org string.prefix.command output }
      if$
      publisher f.publ string.prefix.command output
    }
  if$
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {techreport}
{ output.bibitem.other	% -MWL-
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  format.tr.number output.nonnull
  institution f.org string.prefix.command "institution" output.check
  address f.addr string.prefix.command output
  format.date "year" output.check
  new.block
  note f.note string.prefix.command output
  fin.entry
}

FUNCTION {unpublished}
{ output.bibitem.other	% -MWL-
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  note f.note string.prefix.command "note" output.check
  format.date output
  fin.entry
}

FUNCTION {default.type} { misc }

MACRO {jan} {"January"}

MACRO {feb} {"February"}

MACRO {mar} {"March"}

MACRO {apr} {"April"}

MACRO {may} {"May"}

MACRO {jun} {"June"}

MACRO {jul} {"July"}

MACRO {aug} {"August"}

MACRO {sep} {"September"}

MACRO {oct} {"October"}

MACRO {nov} {"November"}

MACRO {dec} {"December"}

MACRO {acmcs} {"ACM Computing Surveys"}

MACRO {acta} {"Acta Informatica"}

MACRO {cacm} {"Communications of the ACM"}

MACRO {ibmjrd} {"IBM Journal of Research and Development"}

MACRO {ibmsj} {"IBM Systems Journal"}

MACRO {ieeese} {"IEEE Transactions on Software Engineering"}

MACRO {ieeetc} {"IEEE Transactions on Computers"}

MACRO {ieeetcad}
 {"IEEE Transactions on Computer-Aided Design of Integrated Circuits"}

MACRO {ipl} {"Information Processing Letters"}

MACRO {jacm} {"Journal of the ACM"}

MACRO {jcss} {"Journal of Computer and System Sciences"}

MACRO {scp} {"Science of Computer Programming"}

MACRO {sicomp} {"SIAM Journal on Computing"}

MACRO {tocs} {"ACM Transactions on Computer Systems"}

MACRO {tods} {"ACM Transactions on Database Systems"}

MACRO {tog} {"ACM Transactions on Graphics"}

MACRO {toms} {"ACM Transactions on Mathematical Software"}

MACRO {toois} {"ACM Transactions on Office Information Systems"}

MACRO {toplas} {"ACM Transactions on Programming Languages and Systems"}

MACRO {tcs} {"Theoretical Computer Science"}

READ

FUNCTION {sortify}
{ purify$
  "l" change.case$
}

INTEGERS { len }

FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

FUNCTION {sort.format.names}
{ 's :=
  #1 'nameptr :=
  ""
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 >
	{ "   " * }
	'skip$
      if$
      s nameptr "{vv{ } }{ll{ }}{  ff{ }}{  jj{ }}" format.name$ 't :=
      nameptr numnames = t str.others = and
	{ "et al" * }
	{ t sortify * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {sort.format.title}
{ 't :=
  "A " #2
    "An " #3
      "The " #4 t chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}

FUNCTION {author.sort}
{ author empty$
    { key empty$
	{ "to sort, need author or key in " cite$ * warning$
	  ""
	}
	{ key sortify }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.editor.sort}
{ author empty$
    { editor empty$
	{ key empty$
	    { "to sort, need author, editor, or key in " cite$ * warning$
	      ""
	    }
	    { key sortify }
	  if$
	}
	{ editor sort.format.names }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.organization.sort}
{ author empty$
    { organization empty$
	{ key empty$
	    { "to sort, need author, organization, or key in " cite$ * warning$
	      ""
	    }
	    { key sortify }
	  if$
	}
	{ "The " #4 organization chop.word sortify }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {editor.organization.sort}
{ editor empty$
    { organization empty$
	{ key empty$
	    { "to sort, need editor, organization, or key in " cite$ * warning$
	      ""
	    }
	    { key sortify }
	  if$
	}
	{ "The " #4 organization chop.word sortify }
      if$
    }
    { editor sort.format.names }
  if$
}

FUNCTION {presort}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.sort
    { type$ "proceedings" =
	'editor.organization.sort
	{ type$ "manual" =
	    'author.organization.sort
	    'author.sort
	  if$
	}
      if$
    }
  if$
  "    "
  *
  year field.or.null sortify
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}

ITERATE {presort}

% SORT

STRINGS { longest.label }

INTEGERS { number.label longest.label.width }

FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #1 'number.label :=
  #0 'longest.label.width :=
}

FUNCTION {longest.label.pass}
{ number.label int.to.str$ 'label :=
  number.label #1 + 'number.label :=
  label width$ longest.label.width >
    { label 'longest.label :=
      label width$ 'longest.label.width :=
    }
    'skip$
  if$
}

EXECUTE {initialize.longest.label}

ITERATE {longest.label.pass}

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\providecommand{\WileyBibTextsc}{}" write$ newline$
  "\let\textsc\WileyBibTextsc"         write$ newline$
  "\providecommand{\othercit}{}"       write$ newline$
  "\providecommand{\jr}[1]{#1}"        write$ newline$ 
  "\providecommand{\etal}{~et~al.}"    write$ newline$ newline$ newline$
  "\begin{thebibliography}{[" longest.label * "]}" * write$ newline$
}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

EXECUTE {end.bib}

%% end of file

