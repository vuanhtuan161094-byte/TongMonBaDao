using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMBDPilot;

public static class BuildPilotScene
{
    // Use after opening the project with Unity Hub and allowing package import.
    [MenuItem("Tools/TMBD/Create Pilot Scene")]
    public static void CreatePilot()
    {
        const string scenePath = "Assets/Scenes/TMBD_UnityPilot.unity";
        Directory.CreateDirectory("Assets/Scenes");
        Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,
            NewSceneMode.Single);
        GameObject go = new GameObject("TMBD Pilot Bootstrap");
        go.AddComponent<PilotBootstrap>();
        EditorSceneManager.SaveScene(scene, scenePath);
        EditorBuildSettings.scenes = new[]
        {
            new EditorBuildSettingsScene(scenePath, true)
        };
        EditorSceneManager.OpenScene(scenePath);
        Debug.Log("TMBD Unity pilot scene generated. Press Play.");
    }
}
