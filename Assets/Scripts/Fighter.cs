using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class Fighter : MonoBehaviour
{
    private Animator animator;
    public GameObject spinkickParticles;
    public GameObject fireball;

    private Vector3 fireballStartPosition;

	void Start ()
    {
        animator = GetComponent<Animator>();
        fireballStartPosition = fireball.transform.position;
        disableFireball();
    }
	
	void Update ()
    {
        AnimatorStateInfo asi = animator.GetCurrentAnimatorStateInfo(0);

        if(asi.IsName("spinkick"))
        {
            spinkickParticles.GetComponent<ParticleSystem>().Play();
            spinkickParticles.GetComponent<Light>().enabled = true;
        }
        else
        {
            spinkickParticles.GetComponent<ParticleSystem>().Stop();
            spinkickParticles.GetComponent<Light>().enabled = false;
        }

        if(asi.IsName("fireball") && (asi.normalizedTime > 0.6f))
        {
            if(!fireball.activeSelf)
            {
                fireball.SetActive(true);
                Invoke("disableFireball", 3.0f);
            }
        }

        if(fireball.activeSelf)
        {
            fireball.transform.Translate(Vector3.forward * 10.0f * Time.deltaTime);
        }
    }

    void disableFireball()
    {
        fireball.SetActive(false);
        fireball.transform.position = fireballStartPosition;
    }
}
