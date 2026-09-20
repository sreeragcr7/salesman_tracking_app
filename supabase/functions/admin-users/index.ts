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

      const { error } = await adminClient.auth.admin.deleteUser(
        userId,
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
