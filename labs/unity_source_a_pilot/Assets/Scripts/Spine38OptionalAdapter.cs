// To activate ONLY after obtaining an appropriate Spine Editor / Runtimes license:
// 1) Install the official spine-unity 3.8 package compatible with Unity 2020.3.
// 2) Import a legitimately available Spine 3.8 .skel/.atlas/.png triplet.
// 3) Add TMBD_SPINE38 to Player Settings -> Scripting Define Symbols.
// Without these steps, this file compiles as an empty optional extension.
// It neither bundles nor downloads any proprietary runtime.
#if TMBD_SPINE38
using UnityEngine;
using Spine.Unity;

namespace TMBDPilot
{
    [RequireComponent(typeof(SkeletonAnimation))]
    public sealed class Spine38OptionalAdapter : MonoBehaviour
    {
        public SkeletonAnimation Skeleton;
        public string IdleClip = "stand";
        public string WalkClip = "walk";
        public string AttackClip = "attack1";

        private void Awake()
        {
            if (Skeleton == null) Skeleton = GetComponent<SkeletonAnimation>();
        }

        public void PlayIdle() { Play(IdleClip, true); }
        public void PlayWalk() { Play(WalkClip, true); }
        public void PlayAttack() { Play(AttackClip, false); }

        private void Play(string clip, bool loop)
        {
            if (Skeleton == null || Skeleton.AnimationState == null ||
                string.IsNullOrEmpty(clip)) return;
            Skeleton.AnimationState.SetAnimation(0, clip, loop);
        }
    }
}
#endif
