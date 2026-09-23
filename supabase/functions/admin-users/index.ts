import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseAnonKey || !serviceRoleKey) {
      throw new Error("Supabase environment variables are missing.");
    }

    // Client using the user's JWT.
    const userClient = createClient(
      supabaseUrl,
      supabaseAnonKey,
      {
        global: {
          headers: {
            Authorization: req.headers.get("Authorization") ?? "",
          },
        },
      },
    );

    // Verify the currently logged-in user.
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return new Response(
        JSON.stringify({
          error: "You must be logged in.",
        }),
        {
          status: 401,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // Server-side admin client.
    const adminClient = createClient(
      supabaseUrl,
      serviceRoleKey,
    );

    // Check the user's application role.
    const { data: profile, error: profileError } = await adminClient
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (profileError || profile?.role !== "admin") {
      return new Response(
        JSON.stringify({
          error: "Only admins can manage users.",
        }),
        {
          status: 403,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const body = await req.json();

    const action = body.action;

    // =====================================================
    // CREATE SALESMAN
    // =====================================================

    if (action === "create") {
      const name = body.name?.trim();
      const email = body.email?.trim().toLowerCase();
      const password = body.password;
      const profileImage = body.profileImage?.trim() || null;

      if (!name) {
        return new Response(
          JSON.stringify({
            error: "Name is required.",
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      if (!email) {
        return new Response(
          JSON.stringify({
            error: "Email is required.",
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      if (!password || password.length < 6) {
        return new Response(
          JSON.stringify({
            error: "Password must be at least 6 characters.",
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      const {
        data: createdUser,
        error: createUserError,
      } = await adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });

      if (createUserError || !createdUser.user) {
        return new Response(
          JSON.stringify({
            error: createUserError?.message ??
              "Unable to create user.",
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      const newUserId = createdUser.user.id;

      const { error: profileInsertError } = await adminClient
        .from("profiles")
        .insert({
          id: newUserId,
          name,
          email,
          role: "salesman",
          profile_image: profileImage,
        });

      if (profileInsertError) {
        await adminClient.auth.admin.deleteUser(
          newUserId,
        );

        return new Response(
          JSON.stringify({
            error: "User was created but profile creation failed.",
          }),
          {
            status: 500,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      return new Response(
        JSON.stringify({
          success: true,
          userId: newUserId,
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // =====================================================
    // UPDATE SALESMAN
    // =====================================================

    if (action === "update") {
      const userId = body.userId;
      const name = body.name?.trim();
      const email = body.email?.trim().toLowerCase();
      const password = body.password;
      const profileImage = body.profileImage?.trim();

      if (!userId) {
        return new Response(
          JSON.stringify({
            error: "User ID is required.",
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      const updateData: {
        email?: string;
        password?: string;
      } = {};

      if (email) {
        updateData.email = email;
      }

      if (password) {
        if (password.length < 6) {
          return new Response(
            JSON.stringify({
              error: "Password must be at least 6 characters.",
            }),
            {
              status: 400,
              headers: {
                ...corsHeaders,
                "Content-Type": "application/json",
              },
            },
          );
        }

        updateData.password = password;
      }

      if (Object.keys(updateData).length > 0) {
        const { error } = await adminClient.auth.admin.updateUserById(
          userId,
          updateData,
        );

        if (error) {
          return new Response(
            JSON.stringify({
              error: error.message,
            }),
            {
              status: 400,
              headers: {
                ...corsHeaders,
                "Content-Type": "application/json",
              },
            },
          );
        }
      }

      const profileUpdate: {
        name?: string;
        email?: string;
        profile_image?: string | null;
      } = {};

      if (name) {
        profileUpdate.name = name;
      }

      if (email) {
        profileUpdate.email = email;
      }

      if (profileImage !== undefined) {
        profileUpdate.profile_image = profileImage || null;
      }

      const { error: profileError } = await adminClient
        .from("profiles")
        .update(profileUpdate)
        .eq("id", userId);

      if (profileError) {
        return new Response(
          JSON.stringify({
            error: profileError.message,
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      return new Response(
        JSON.stringify({
          success: true,
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // =====================================================
    // DELETE SALESMAN
    // =====================================================

    if (action === "delete") {
      const userId = body.userId;

      if (!userId) {
        return new Response(
          JSON.stringify({
            error: "User ID is required.",
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      // Get the profile image before deleting the profile.
      const {
        data: profile,
        error: profileError,
      } = await adminClient
        .from("profiles")
        .select("profile_image")
        .eq("id", userId)
        .maybeSingle();

      if (profileError) {
        return new Response(
          JSON.stringify({
            error: profileError.message,
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      // Get all trips belonging to the salesman.
      const {
        data: trips,
        error: tripsError,
      } = await adminClient
        .from("trips")
        .select("id")
        .eq("user_id", userId);

      if (tripsError) {
        return new Response(
          JSON.stringify({
            error: tripsError.message,
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      // Delete visit media belonging to each trip.
      for (const trip of trips ?? []) {
        const tripId = trip.id;

        const {
          data: files,
          error: listError,
        } = await adminClient.storage
          .from("visit-media")
          .list(tripId);

        if (listError) {
          return new Response(
            JSON.stringify({
              error: listError.message,
            }),
            {
              status: 400,
              headers: {
                ...corsHeaders,
                "Content-Type": "application/json",
              },
            },
          );
        }

        if (files && files.length > 0) {
          const filePaths = files
            .filter((file) => file.name)
            .map(
              (file) => `${tripId}/${file.name}`,
            );

          if (filePaths.length > 0) {
            const {
              error: removeError,
            } = await adminClient.storage
              .from("visit-media")
              .remove(filePaths);

            if (removeError) {
              return new Response(
                JSON.stringify({
                  error: removeError.message,
                }),
                {
                  status: 400,
                  headers: {
                    ...corsHeaders,
                    "Content-Type": "application/json",
                  },
                },
              );
            }
          }
        }
      }

      // Delete the salesman profile image if one exists.
      if (profile?.profile_image) {
        const profileImageUrl = profile.profile_image;

        const marker = "/storage/v1/object/public/profile-images/";

        const markerIndex = profileImageUrl.indexOf(marker);

        if (markerIndex !== -1) {
          const filePath = decodeURIComponent(
            profileImageUrl.substring(
              markerIndex + marker.length,
            ),
          );

          if (filePath) {
            const {
              error: removeProfileImageError,
            } = await adminClient.storage
              .from("profile-images")
              .remove([filePath]);

            if (removeProfileImageError) {
              return new Response(
                JSON.stringify({
                  error: removeProfileImageError.message,
                }),
                {
                  status: 400,
                  headers: {
                    ...corsHeaders,
                    "Content-Type": "application/json",
                  },
                },
              );
            }
          }
        }
      }

      // Finally delete the Auth user.
      const {
        error: deleteUserError,
      } = await adminClient.auth.admin.deleteUser(
        userId,
      );

      if (deleteUserError) {
        return new Response(
          JSON.stringify({
            error: deleteUserError.message,
          }),
          {
            status: 400,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
            },
          },
        );
      }

      return new Response(
        JSON.stringify({
          success: true,
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    return new Response(
      JSON.stringify({
        error: "Invalid action.",
      }),
      {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  } catch (error) {
    console.error(error);

    return new Response(
      JSON.stringify({
        error: "Internal server error.",
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }
});
