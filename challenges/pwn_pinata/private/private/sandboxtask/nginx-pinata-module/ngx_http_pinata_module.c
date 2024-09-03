#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>
#include <unistd.h>

#define likely(x)      __builtin_expect(!!(x), 1)
#define unlikely(x)    __builtin_expect(!!(x), 0)

int DEBUG = 0;

static char *ngx_http_pinata(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
static ngx_int_t ngx_http_pinata_handler(ngx_http_request_t *r);
static int decode_credentials(char *src);

static ngx_command_t ngx_http_pinata_commands[] = {
  {
    ngx_string("pinata"),
    NGX_HTTP_LOC_CONF|NGX_CONF_NOARGS,
    ngx_http_pinata,
    0,
    0,
    NULL
  },
  ngx_null_command
};

static ngx_http_module_t ngx_http_pinata_module_ctx = {
  NULL, /* preconfiguration */
  NULL, /* postconfiguration */

  NULL, /* create main configuration */
  NULL, /* init main configuration */

  NULL, /* create server configuration */
  NULL, /* merge server configuration */

  NULL, /* create location configuration */
  NULL /* merge location configuration */
};

ngx_module_t ngx_http_pinata_module = {
  NGX_MODULE_V1,
  &ngx_http_pinata_module_ctx,
  ngx_http_pinata_commands,
  NGX_HTTP_MODULE,
  NULL, /* init master */
  NULL, /* init module */
  NULL, /* init process */
  NULL, /* init thread */
  NULL, /* exit thread */
  NULL, /* exit process */
  NULL, /* exit master */
  NGX_MODULE_V1_PADDING
};

void timeout_handler(int signum) {
  printf("Timed out, exiting...\n");
  exit(1);
}

void debug() {
    // adjust the binary so this stop gadget is the first thing encountered
    // while guessing rip byte by byte
    asm(".rept 153; nop ; .endr");
    ssize_t n = write(3, "~~~ DEBUG: the module works! ~~~", 32);
    (void)n; // ignore result so compiler doesn't complain
    exit(1);
}

static ngx_int_t ngx_http_pinata_handler(ngx_http_request_t *r)
{
  if (DEBUG) { debug(); }

  signal(SIGALRM, timeout_handler);
  alarm(1);

  ngx_buf_t *b;
  ngx_chain_t out;

  /* Allocate a new buffer for sending out the reply. */
  b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));

  out.buf = b;
  out.next = NULL;
  b->memory = 1;
  b->last_buf = 1;
  const char* body = "";

  if (r->headers_in.authorization) {
    char* header = (char*)r->headers_in.authorization->value.data;
    if (likely(strlen(header) > 6 && !strncmp((const char*)header, "Basic ", 6))) {
      decode_credentials(header + 6);

      // pretend there is a password
      body = "Wrong user/password";
      r->headers_out.status = 401;
    } else {
      body = "Invalid authorization header";
      r->headers_out.status = 401;
    }
  }
  else {
    ngx_table_elt_t *h;
    h = ngx_list_push(&r->headers_out.headers);
    if (h == NULL) {
        return NGX_ERROR;
    }
    ngx_str_t key = ngx_string("WWW-Authenticate");
    h->key = key;
    ngx_str_t value = ngx_string("Basic");
    h->value = value;
    h->hash = 1;

    body = "Unauthorized";
    r->headers_out.status = 401;
  }

  b->pos = (u_char*)body;
  b->last = (u_char*)body + strlen(body);
  r->headers_out.content_length_n = strlen(body);

  r->headers_out.content_type.len = sizeof("text/plain") - 1;
  r->headers_out.content_type.data = (u_char*)"text/plain";

  ngx_http_send_header(r);
  return ngx_http_output_filter(r, &out);
}

static int __attribute__ ((noinline)) decode_credentials(char* str) {
  ngx_str_t src;
  src.data = (unsigned char*) str;
  src.len = strlen(str);
  unsigned char buf[16] = {0};
  ngx_str_t dst;
  dst.data = buf;
  dst.len = 0;

  ngx_decode_base64(&dst, &src);

  src.data = 0; // prevent inf loops when jumping back

  //asm("movq $1337, %rdx");

  return dst.len;
}

static char *ngx_http_pinata(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
  ngx_http_core_loc_conf_t *clcf;

  clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);
  clcf->handler = ngx_http_pinata_handler;

  return NGX_CONF_OK;
}
