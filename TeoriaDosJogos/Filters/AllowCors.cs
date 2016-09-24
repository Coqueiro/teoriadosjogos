using System;
using System.Web.Mvc;

namespace TeoriaDosJogos.Filters
{
    public class AllowCorsAttribute : ActionFilterAttribute
    {
        private const string ORIGIN_HEADER = "Origin";

        private const string ALLOWED_DOMAIN = "*";

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var isLocalRequest = filterContext.RequestContext.HttpContext.Request.IsLocal;

            if (isLocalRequest)
            {
                CreateCorsHeaders(filterContext, "*");
            }
            else if (IsOriginAllowed(filterContext))
            {
                CreateCorsHeaders(filterContext, filterContext.RequestContext.HttpContext.Request.Headers[ORIGIN_HEADER]);
            }

            base.OnActionExecuting(filterContext);
        }

        private bool IsOriginAllowed(ActionExecutingContext filterContext)
        {
            var originHeaderValue = filterContext.RequestContext.HttpContext.Request.Headers[ORIGIN_HEADER];

            if (string.IsNullOrWhiteSpace(originHeaderValue))
            {
                return false;
            }

            Uri originUri;
            Uri.TryCreate(originHeaderValue, UriKind.RelativeOrAbsolute, out originUri);

            return originUri != null && originUri.Host.EndsWith(ALLOWED_DOMAIN);
        }

        private void CreateCorsHeaders(ActionExecutingContext filterContext, string accessControlAllowOrigin)
        {
            filterContext.RequestContext.HttpContext.Response.AddHeader("Access-Control-Allow-Origin", accessControlAllowOrigin);
            filterContext.RequestContext.HttpContext.Response.AddHeader("Access-Control-Allow-Methods", "GET, POST");
            filterContext.RequestContext.HttpContext.Response.AddHeader("Access-Control-Allow-Credentials", "true");
            filterContext.RequestContext.HttpContext.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");
        }
    }
}