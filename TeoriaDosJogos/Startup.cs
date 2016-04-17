using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(TeoriaDosJogos.Startup))]
namespace TeoriaDosJogos
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
