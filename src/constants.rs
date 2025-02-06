#[cfg(windows)]
pub static LIBRARY: &str = "vencord_launcher";

#[cfg(not(windows))]
pub static LIBRARY: &str = "libvencord_launcher.so";

pub static MOD_ENTRYPOINT: &str = "patcher.js";
pub static RELEASE_URL: &str = "https://api.github.com/repos/vendicated/vencord/releases/latest";
pub static RELEASE_URL_FALLBACK: &str = "https://vencord.dev/releases/vencord";
pub static RELEASE_INFO_FILE: &str = "release.json";
pub static RELEASE_ASSETS: &[&str] = &[
    // Patcher
    "patcher.js",
    "patcher.js.map",
    "patcher.js.LEGAL.txt",
    // Preload
    "preload.js",
    "preload.js.map",
    // Renderer JS
    "renderer.js",
    "renderer.js.map",
    "renderer.js.LEGAL.txt",
    // Renderer CSS
    "renderer.css",
    "renderer.css.map",
];

pub fn get_library_path() -> String {
    // Get the executable dir
    let executable_dir = std::env::current_exe().ok().and_then(|exe_path| {
        exe_path
            .parent()
            .map(|parent_path| parent_path.to_path_buf())
    });

    // If the executable dir contains the library, return that path
    if let Some(dir) = executable_dir {
        let lib_path = dir.join(LIBRARY);
        if lib_path.exists() {
            return lib_path.to_str().unwrap().to_string();
        }
    }

    // If the current dir contains the library, return that path
    if let Ok(dir) = std::env::current_dir() {
        let lib_path = dir.join(LIBRARY);
        if lib_path.exists() {
            return lib_path.to_str().unwrap().to_string();
        }
    }

    // If neither paths contain the dir, hope it's in a registered libary path
    LIBRARY.to_string()
}

pub fn asset_cache_dir() -> Option<std::path::PathBuf> {
    let local_appdata = dirs::data_local_dir()?;

    let dir = local_appdata.join("VencordLauncher").join("cache");

    if !dir.exists() {
        std::fs::create_dir_all(&dir).ok()?;
    }

    Some(dir)
}
