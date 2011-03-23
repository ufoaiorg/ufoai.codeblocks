# This is a shell script that is sourced, not executed. It uses
# functions and scripts from tml@iki.fi's work envíronment and is
# included only for reference

MOD=gettext
VER=0.17-1
THIS=$MOD-$VER
HEX=`echo $THIS | md5sum | cut -d' ' -f1`
DEPS=

patch -p0 <<'EOF'
--- /dev/null
+++ gettext-runtime/intl/intl.def
@@ -0,0 +1,30 @@
+LIBRARY intl.dll
+EXPORTS
+_nl_msg_cat_cntr DATA
+bind_textdomain_codeset
+bindtextdomain
+dcgettext
+dcngettext
+dgettext
+dngettext
+gettext
+libintl_bind_textdomain_codeset
+libintl_bindtextdomain
+libintl_dcgettext
+libintl_dcngettext
+libintl_dgettext
+libintl_dngettext
+libintl_fprintf
+libintl_gettext
+libintl_ngettext
+libintl_printf
+libintl_set_relocation_prefix
+libintl_snprintf
+libintl_sprintf
+libintl_textdomain
+libintl_vfprintf
+libintl_vprintf
+libintl_vsprintf
+libintl_vsnprintf
+ngettext
+textdomain
--- gettext-runtime/intl/printf.c
+++ gettext-runtime/intl/printf.c
@@ -69,7 +69,7 @@
 #define STATIC static
 
 /* This needs to be consistent with libgnuintl.h.in.  */
-#if defined __NetBSD__ || defined __BEOS__ || defined __CYGWIN__ || defined __MINGW32__
+#if defined __NetBSD__ || defined __BEOS__ || defined __CYGWIN__
 /* Don't break __attribute__((format(printf,M,N))).
    This redefinition is only possible because the libc in NetBSD, Cygwin,
    mingw does not have a function __printf__.  */
--- gettext-runtime/intl/libgnuintl.h.in
+++ gettext-runtime/intl/libgnuintl.h.in
@@ -330,7 +330,7 @@
 extern int vfprintf (FILE *, const char *, va_list);
 
 #undef printf
-#if defined __NetBSD__ || defined __BEOS__ || defined __CYGWIN__ || defined __MINGW32__
+#if defined __NetBSD__ || defined __BEOS__ || defined __CYGWIN__
 /* Don't break __attribute__((format(printf,M,N))).
    This redefinition is only possible because the libc in NetBSD, Cygwin,
    mingw does not have a function __printf__.  */
diff -ru C:/DOCUME~1/tml/LOCALS~1/Temp/gettext-0.17/gettext-runtime/intl/Makefile.in ./gettext-runtime/intl/Makefile.in
--- C:/DOCUME~1/tml/LOCALS~1/Temp/gettext-0.17/gettext-runtime/intl/Makefile.in	2007-11-04 23:21:12.000000000 +0200
+++ gettext-runtime/intl/Makefile.in	2007-11-26 01:59:34.599000000 +0200
@@ -85,7 +85,7 @@
 CPPFLAGS = @CPPFLAGS@
 CFLAGS = @CFLAGS@ @CFLAG_VISIBILITY@
 LDFLAGS = @LDFLAGS@ $(LDFLAGS_@WOE32DLL@)
-LDFLAGS_yes = -Wl,--export-all-symbols
+LDFLAGS_yes =
 LDFLAGS_no =
 LIBS = @LIBS@
 
@@ -179,8 +179,9 @@
 libgnuintl.h_vms Makefile.vms libgnuintl.h.msvc-static \
 libgnuintl.h.msvc-shared Makefile.msvc
 
-all: all-@USE_INCLUDED_LIBINTL@
-all-yes: libintl.$la libintl.h charset.alias ref-add.sed ref-del.sed
+all: all-@USE_INCLUDED_LIBINTL@-@WOE32DLL@
+all-yes-no: libintl.$la libintl.h charset.alias ref-add.sed ref-del.sed
+all-yes-yes: intl.$la libintl.h charset.alias ref-add.sed ref-del.sed
 all-no: all-no-@BUILD_INCLUDED_LIBINTL@
 all-no-yes: libgnuintl.$la
 all-no-no:
@@ -199,6 +200,16 @@
 	  -rpath $(libdir) \
 	  -no-undefined
 
+intl.la: $(OBJECTS) $(OBJECTS_RES_@WOE32@)
+	$(LIBTOOL) --mode=link \
+	  $(CC) $(CPPFLAGS) $(CFLAGS) $(XCFLAGS) $(LDFLAGS) -o $@ \
+	  $(OBJECTS) @LTLIBICONV@ @INTL_MACOSX_LIBS@ $(LIBS) @LTLIBTHREAD@ @LTLIBC@ \
+	  -Wl,$(OBJECTS_RES_@WOE32@) -Wl,$(srcdir)/intl.def \
+	  -module -avoid-version \
+	  -rpath $(libdir) \
+	  -no-undefined
+	  cp intl.$la libintl.$la
+
 # Libtool's library version information for libintl.
 # Before making a gettext release, the gettext maintainer must change this
 # according to the libtool documentation, section "Library interface versions".
@@ -337,11 +348,11 @@
 # If you want to use the one which comes with this version of the
 # package, you have to use `configure --with-included-gettext'.
 install: install-exec install-data
-install-exec: all
+
+install-libintl-no:
 	if { test "$(PACKAGE)" = "gettext-runtime" || test "$(PACKAGE)" = "gettext-tools"; } \
 	   && test '@USE_INCLUDED_LIBINTL@' = yes; then \
-	  $(mkdir_p) $(DESTDIR)$(libdir) $(DESTDIR)$(includedir); \
-	  $(INSTALL_DATA) libintl.h $(DESTDIR)$(includedir)/libintl.h; \
+	  $(mkdir_p) $(DESTDIR)$(libdir); \
 	  $(LIBTOOL) --mode=install \
 	    $(INSTALL_DATA) libintl.$la $(DESTDIR)$(libdir)/libintl.$la; \
 	  if test "@RELOCATABLE@" = yes; then \
@@ -353,6 +364,31 @@
 	else \
 	  : ; \
 	fi
+
+install-libintl-yes:
+	if { test "$(PACKAGE)" = "gettext-runtime" || test "$(PACKAGE)" = "gettext-tools"; } \
+	   && test '@USE_INCLUDED_LIBINTL@' = yes; then \
+	  $(mkdir_p) $(DESTDIR)$(libdir) $(DESTDIR)$(libdir)/../bin; \
+	  $(LIBTOOL) --mode=install \
+	    $(INSTALL_DATA) intl.$la $(DESTDIR)$(libdir)/intl.$la; \
+	  if test "@RELOCATABLE@" = yes; then \
+	    dependencies=`sed -n -e 's,^dependency_libs=\(.*\),\1,p' < $(DESTDIR)$(libdir)/intl.la | sed -e "s,^',," -e "s,'\$$,,"`; \
+	  fi; \
+	  rm -f $(DESTDIR)$(libdir)/intl.$la; \
+	  mv $(DESTDIR)$(libdir)/intl.dll.a $(DESTDIR)$(libdir)/libintl.dll.a; \
+	  mv $(DESTDIR)$(libdir)/intl.dll $(DESTDIR)$(libdir)/../bin; \
+	else \
+	  : ; \
+	fi
+
+install-exec: all install-libintl-@WOE32DLL@
+	if { test "$(PACKAGE)" = "gettext-runtime" || test "$(PACKAGE)" = "gettext-tools"; } \
+	   && test '@USE_INCLUDED_LIBINTL@' = yes; then \
+	  $(mkdir_p) $(DESTDIR)$(libdir) $(DESTDIR)$(includedir); \
+	  $(INSTALL_DATA) libintl.h $(DESTDIR)$(includedir)/libintl.h; \
+	else \
+	  : ; \
+	fi
 	if test "$(PACKAGE)" = "gettext-tools" \
 	   && test '@USE_INCLUDED_LIBINTL@' = no \
 	   && test @GLIBC2@ != no; then \
@@ -395,6 +431,7 @@
 	else \
 	  : ; \
 	fi
+
 install-data: all
 	if test "$(PACKAGE)" = "gettext-tools"; then \
 	  $(mkdir_p) $(DESTDIR)$(gettextsrcdir); \
EOF

usedev
usemsvs6

CC='gcc -mtune=pentium3' CFLAGS=-O2 ./configure --disable-static --disable-java --enable-relocatable --disable-openmp --disable-largefile --with-libiconv-prefix=/opt/win_iconv --prefix=c:/devel/target/$HEX &&
sed -e 's/need_relink=yes/need_relink=no/' <gettext-tools/libtool >gettext-tools/libtool.temp && mv gettext-tools/libtool.temp gettext-tools/libtool &&
PATH=/devel/target/$HEX/bin:$PATH make install &&
(cd /devel/target/$HEX &&
zip /tmp/gettext-runtime-$VER.zip bin/intl.dll &&
zip /tmp/gettext-runtime-$VER.zip lib/charset.alias &&
zip /tmp/gettext-runtime-dev-$VER.zip lib/libintl.dll.a &&
(cd bin && pexports intl.dll >../lib/intl.def && cd ../lib && lib -def:intl.def -out:intl.lib) &&
zip /tmp/gettext-runtime-dev-$VER.zip lib/intl.def lib/intl.lib &&
zip /tmp/gettext-runtime-dev-$VER.zip include/libintl.h &&
zip /tmp/gettext-tools-$VER.zip bin/autopoint bin/gettextize bin/*.sh bin/*.exe &&
zip /tmp/gettext-tools-$VER.zip bin/lib*.dll &&
zip /tmp/gettext-tools-$VER.zip include/autosprintf.h include/gettext-po.h &&
zip -r /tmp/gettext-tools-$VER.zip lib/GNU.Gettext.dll &&
zip -r /tmp/gettext-tools-$VER.zip lib/gettext share) &&
(cd /devel/src/tml && zip /tmp/gettext-runtime-dev-$VER.zip make/$THIS.sh) &&
manifestify /tmp/gettext-runtime-$VER.zip &&
manifestify /tmp/gettext-runtime-dev-$VER.zip &&
manifestify /tmp/gettext-tools-$VER.zip
