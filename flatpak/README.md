Build
```sh
flatpak-builder --force-clean --user --install-deps-from=flathub --repo=repo --install builddir io.github.teamrecomp.sawbladerecomp.json
```

Bundle
```sh
flatpak build-bundle repo io.github.teamrecomp.sawbladerecomp.flatpak io.github.teamrecomp.sawbladerecomp --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
```

