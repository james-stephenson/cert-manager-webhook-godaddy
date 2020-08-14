load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")
load("@bazel_gazelle//:def.bzl", "gazelle")
load("@io_k8s_repo_infra//defs:pkg.bzl", "pkg_tar")
load("//rules:container.bzl", "multi_arch_container", "multi_arch_container_push")
load("//rules:platforms.bzl", "SERVER_PLATFORMS", "for_platforms")

DOCKERIZED_BINARIES = {
    "webhook-godaddy": {
        "target": "//:cert-manager-webhook-godaddy",
    },
}

# gazelle:prefix github.com/james-stephenson/cert-manager-webhook-godaddy
# gazelle:proto disable_global
gazelle(name = "gazelle")

go_library(
    name = "go_default_library",
    srcs = ["main.go"],
    importpath = "github.com/james-stephenson/cert-manager-webhook-godaddy",
    visibility = ["//visibility:private"],
    deps = [
        "@com_github_jetstack_cert_manager//pkg/acme/webhook/apis/acme/v1alpha1:go_default_library",
        "@com_github_jetstack_cert_manager//pkg/acme/webhook/cmd:go_default_library",
        "@com_github_jetstack_cert_manager//pkg/apis/meta/v1:go_default_library",
        "@com_github_jetstack_cert_manager//pkg/issuer/acme/dns/util:go_default_library",
        "@com_github_jetstack_cert_manager//pkg/util:go_default_library",
        "@io_k8s_apiextensions_apiserver//pkg/apis/apiextensions/v1beta1:go_default_library",
        "@io_k8s_apimachinery//pkg/apis/meta/v1:go_default_library",
        "@io_k8s_client_go//kubernetes:go_default_library",
        "@io_k8s_client_go//rest:go_default_library",
    ],
)

go_binary(
    name = "cert-manager-webhook-godaddy",
    embed = [":go_default_library"],
    visibility = ["//visibility:public"],
)

go_test(
    name = "go_default_test",
    srcs = ["main_test.go"],
    data = glob(["testdata/**"]),
    embed = [":go_default_library"],
    deps = ["@com_github_jetstack_cert_manager//test/acme/dns:go_default_library"],
)

[multi_arch_container(
    name = binary,
    architectures = SERVER_PLATFORMS["linux"],
    base = "@static_base//image",
    binary = select(for_platforms(
        for_server = meta["target"],
        only_os = "linux",
    )),
    docker_push_tags = {
        "{{STABLE_DOCKER_REGISTRY}}/cert-manager-%s-{ARCH}:{{STABLE_DOCKER_TAG}}" % binary: "%s.image" % binary
        for binary in DOCKERIZED_BINARIES.keys()
    },
    # Since the multi_arch_container macro replaces the {ARCH} format string,
    # we need to escape the stamping vars.
    docker_tags = ["{{STABLE_DOCKER_REGISTRY}}/cert-manager-%s-{ARCH}:{{STABLE_DOCKER_TAG}}" % binary],
    stamp = True,
    symlinks = {
        # Some cluster startup scripts expect to find the binaries in /usr/local/bin,
        # but the debs install the binaries into /usr/bin.
        "/usr/local/bin/" + binary: "/usr/bin/" + binary,
    },
    tags = ["manual"],
    user = "1000",
    visibility = ["//visibility:private"],
) for binary, meta in DOCKERIZED_BINARIES.items()]

# Also roll up all images into a single bundle to push with one target.
#multi_arch_container_push(
#    name = "server-images",
#    architectures = SERVER_PLATFORMS["linux"],
#    docker_tags_images = {
#        "{{STABLE_DOCKER_REGISTRY}}/cert-manager-%s-{ARCH}:{{STABLE_DOCKER_TAG}}" % binary: "%s.image" % binary
#        for binary in DOCKERIZED_BINARIES.keys()
#    },
#    tags = ["manual"],
#)

#[pkg_tar(
#    name = "%s-data-%s.tar" % (binary, arch),
#    srcs = select({"@io_bazel_rules_go//go/platform:" + arch: ["//:" + binary]}),
#    mode = "0755",
#    package_dir = "/usr/bin",
#    tags = ["manual"],
#    visibility = ["//visibility:private"],
#) for binary in DOCKERIZED_BINARIES.keys() for arch in SERVER_PLATFORMS["linux"]]
#
#[multi_arch_container(
#    name = binary,
#    architectures = SERVER_PLATFORMS["linux"],
#    base = "@static_base//image",
#    # Since the multi_arch_container macro replaces the {ARCH} format string,
#    # we need to escape the stamping vars.
#    docker_tags = ["{{STABLE_DOCKER_REGISTRY}}/cert-manager-%s-{ARCH}:{{STABLE_DOCKER_TAG}}" % binary],
#    stamp = True,
#    symlinks = {
#        # Some cluster startup scripts expect to find the binaries in /usr/local/bin,
#        # but the debs install the binaries into /usr/bin.
#        "/usr/local/bin/" + binary: "/usr/bin/" + binary,
#    },
#    tags = ["manual"],
#    tars = select(for_platforms(
#        for_server = [":%s-data-{ARCH}.tar" % binary],
#        only_os = "linux",
#    )),
#    user = "1000",
#    visibility = ["//visibility:private"],
#) for binary, meta in DOCKERIZED_BINARIES.items()]
