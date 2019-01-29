from leapp.snactor.fixture import current_actor_context
from leapp.models import ActiveKernelModule, ActiveKernelModulesFacts, CheckResult


def create_modulesfacts(kernel_modules):
    return ActiveKernelModulesFacts(kernel_modules=kernel_modules)


def test_actor_with_btrfs_module(current_actor_context):
    with_btrfs = [
        ActiveKernelModule(filename='btrfs', parameters=[]),
        ActiveKernelModule(filename='kvm', parameters=[])]

    current_actor_context.feed(create_modulesfacts(kernel_modules=with_btrfs))
    current_actor_context.run()
    assert current_actor_context.consume(CheckResult)


def test_actor_without_btrfs_module(current_actor_context):
    without_btrfs = [
        ActiveKernelModule(filename='kvm_intel', parameters=[]),
        ActiveKernelModule(filename='kvm', parameters=[])]

    current_actor_context.feed(create_modulesfacts(kernel_modules=without_btrfs))
    current_actor_context.run()
    assert not current_actor_context.consume(CheckResult)

