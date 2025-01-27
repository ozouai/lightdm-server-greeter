#include "interop.h"
#include <lightdm.h>

LightDMGreeter *greeter;
void (*storedCallback)(int);
unsigned char* storedPassword;

void authentication_complete_cb(LightDMGreeter *greeter, void* empty)
{
    g_message("Got authentication complete");
    if (!lightdm_greeter_get_is_authenticated(greeter)) {
        g_message("Authentication failure");
        storedCallback(-1);
        return;
    }
    const gchar *default_session = lightdm_greeter_get_default_session_hint(greeter);
    const GList *sessions = lightdm_get_sessions();
    // for(GList *item = sessions; item; item = item->next) {
    //     LightDMSession *session = item->data;

    // }
    if(!lightdm_greeter_start_session_sync(greeter, default_session, NULL)) {
        g_message("Error starting session");
        storedCallback(-2);
        return;
    }
    storedCallback(1);
}

void show_prompt_cb(LightDMGreeter *greeter, const char *text, LightDMPromptType type) {
    g_message("Got prompt message");
    g_message(text);

    if(!lightdm_greeter_respond(greeter, storedPassword, NULL)) {
        storedPassword = NULL;
        storedCallback(-1);
        return;
    }
    storedPassword = NULL;
}

int initialize() {
    greeter = lightdm_greeter_new();
    if(!lightdm_greeter_connect_sync(greeter, NULL)) {
        return -1;
    }
    g_signal_connect(greeter, "authentication-complete", G_CALLBACK(authentication_complete_cb), NULL);
    g_signal_connect(greeter, LIGHTDM_GREETER_SIGNAL_SHOW_PROMPT, G_CALLBACK(show_prompt_cb), NULL);
    // lightdm_greeter_authenticate(greeter, "foo", NULL);
    return 1;
}

int attemptLogin(unsigned char *username, unsigned char *password, void (*callback)(int)) {
    storedPassword = password;
    if(!lightdm_greeter_authenticate(greeter, username, NULL)) {
        storedPassword = NULL;
        return -1;
    }

    storedCallback = callback;
    return 1;
}