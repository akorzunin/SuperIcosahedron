FROM debian:bookworm-slim@sha256:88200866dfff7ea7f5cbcb6ec7c8a701889efe6fe859fe64d6990e4b07ea4171 AS builder

# Snapshot also pins transitive Debian packages; advance deliberately for updates.
RUN rm /etc/apt/sources.list.d/debian.sources && \
    printf 'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20260909T000000Z bookworm main\n' > /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl unzip python3 openjdk-17-jdk-headless \
      libfontconfig1 libx11-6 libxcursor1 libxinerama1 libxrandr2 libxi6 libgl1 libasound2 && \
    rm -rf /var/lib/apt/lists/*

ENV GODOT_VERSION=4.7.2 \
    ANDROID_HOME=/opt/android-sdk \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    GODOT_SILENCE_ROOT_WARNING=1

WORKDIR /tmp/downloads
COPY docker/game.sha512 docker/android.sha256 ./
RUN curl -fL --retry 3 -O https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip && \
    curl -fL --retry 3 -O https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz && \
    sha512sum -c game.sha512 && \
    unzip -q Godot_v4.7.2-stable_linux.x86_64.zip && \
    install -m 755 Godot_v4.7.2-stable_linux.x86_64 /usr/local/bin/godot && \
    unzip -q Godot_v4.7.2-stable_export_templates.tpz && \
    mkdir -p /root/.local/share/godot/export_templates && \
    mv templates /root/.local/share/godot/export_templates/4.7.2.stable && \
    rm Godot_*

RUN curl -fL --retry 3 -O https://dl.google.com/android/repository/build-tools_r36.1_linux.zip && \
    curl -fL --retry 3 -O https://dl.google.com/android/repository/platform-tools_r36.0.2-linux.zip && \
    sha256sum -c android.sha256 && \
    mkdir -p "$ANDROID_HOME/build-tools" && \
    unzip -q build-tools_r36.1_linux.zip && \
    mv android-16 "$ANDROID_HOME/build-tools/36.1.0" && \
    unzip -q platform-tools_r36.0.2-linux.zip -d "$ANDROID_HOME" && \
    rm *.zip && \
    mkdir -p /root/.config/godot && \
    keytool -genkeypair -keystore /root/.config/godot/debug.keystore \
      -storepass android -alias androiddebugkey -keypass android \
      -dname 'CN=Android Debug,O=Android,C=US' -keyalg RSA -keysize 2048 -validity 10000 && \
    printf '[gd_resource type="EditorSettings" format=3]\n\n[resource]\nexport/android/java_sdk_path = "%s"\nexport/android/android_sdk_path = "%s"\nexport/android/debug_keystore = "/root/.config/godot/debug.keystore"\nexport/android/debug_keystore_user = "androiddebugkey"\nexport/android/debug_keystore_pass = "android"\n' \
      "$JAVA_HOME" "$ANDROID_HOME" > /root/.config/godot/editor_settings-4.7.tres

WORKDIR /source
COPY project.godot export_presets.cfg default_bus_layout.tres ./
COPY game/ game/
COPY addons/ addons/
COPY test/ test/
COPY dev/ dev/
COPY docker/export.py /opt/export.py

FROM builder AS export
ARG TARGET=all
ARG GAME_VERSION=dev
ARG GAME_COMMIT=unknown
ARG DISCORD_APP_ID=0
# Toolchain downloads happen above; tests and exports must work offline.
RUN --network=none python3 /opt/export.py "$TARGET"

FROM scratch AS artifacts
COPY --from=export /out/ /
