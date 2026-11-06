import application;

pragma(mangle, "main")
extern(C) int main() {
    Application app;
    app.RunLoop();
}