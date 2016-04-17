package com.example.helloendpoints;

import java.util.LinkedList;
import java.util.List;

/**
 * Created by Daniel on 4/16/16.
 */
public class MemberList {

    public List<String> memberNames;

    public MemberList() {
        this.memberNames = new LinkedList<>();
    }

    public MemberList(List<String> memberIds) {
        this.memberNames = memberIds;
    }

    public List<String> getMemberNames() {
        return memberNames;
    }

    public void setMemberNames(List<String> memberNames) {
        this.memberNames = memberNames;
    }
}
