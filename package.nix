{ lib
, rustPlatform
, backend-src
, frontend-src
}:

rustPlatform.buildRustPackage rec {
  pname = "librespeed-rs";
  version = "unstable-${lib.substring 0 8 backend-src.lastModifiedDate}-${backend-src.shortRev}";  # Dynamic: unstable-<date>-<short-git-hash>

  src = backend-src;

  cargoHash = "sha256-rtlHCjeyhKFV2DfW/jQFNyX8XskzYawva0v1kyNd53k=";

  postInstall = ''
    mkdir -p $out/share/librespeed/assets
    cp ${frontend-src}/examples/example-singleServer-gauges.html $out/share/librespeed/assets/index.html
    cp ${frontend-src}/speedtest.js $out/share/librespeed/assets/
    cp ${frontend-src}/speedtest_worker.js $out/share/librespeed/assets/
    cp ${frontend-src}/favicon.ico $out/share/librespeed/assets/  # Optional but nice for the UI

    # Adjust paths in index.html to load JS from the same directory (original assumes parent dir)
    sed -i 's|../speedtest.js|speedtest.js|g' $out/share/librespeed/assets/index.html
    sed -i 's|../speedtest_worker.js|speedtest_worker.js|g' $out/share/librespeed/assets/index.html

    # Configure the frontend to use the backend API at /backend/ (adjust if you change baseUrl in the module)
    sed -i 's|https://your-backend-here/example/|/backend/|g' $out/share/librespeed/assets/index.html
  '';

  meta = with lib; {
    description = "Rust backend for LibreSpeed speed test, with integrated frontend";
    homepage = "https://github.com/librespeed/speedtest-rust";
    # license = licenses.lgpl3Plus;
    maintainers = [ maintainers.rbbrown1 ];
    platforms = platforms.linux;
  };
}
